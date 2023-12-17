// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Combine
import JudoDocument
import SwiftUI

struct DataSourceView: SwiftUI.View {
    @Environment(\.data) private var data
    @EnvironmentObject private var componentState: ComponentState
    @State private var fetchedData: Any?
    @State private var refreshTimer: Timer?

    var dataSource: DataSourceNode

    var body: some SwiftUI.View {
        if fetchedData == nil {
            nodesView
                .environment(\.data, fetchedData)
                .onReceive(dataPublisher) { result in
                    guard case let Result.success(fetchedData) = result else {
                        return
                    }

                    self.fetchedData = fetchedData
                }
        } else {
            if #available(iOS 15.0, *) {
                nodesView
                    .environment(\.data, fetchedData)
                    .refreshable {
                        await refresh()
                    }
            } else {
                nodesView
                    .environment(\.data, fetchedData)
            }
        }
    }

    private var nodesView: some SwiftUI.View {
        ForEach(dataSource.children, id: \.id) {
            NodeView(node: $0)
        }
        .onDisappear() {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
        .onAppear() {
            refreshTimer = setupRefreshTimerIfNeeded()
        }
    }

    private var dataPublisher: AnyPublisher<Result<Any?, Error>, Never> {

        struct UnableToInterpolateDataSourceURLError: Swift.Error {
            var errorDescription: String {
                "Unable to evaluate expressions in Data Source URL"
            }
        }

        do {
            let request = try dataSource.urlRequest(data: data, propertyValues: componentState.propertyValues)
            return URLSession.shared.dataPublisher(for: request)
        } catch {
            return Just(Result.failure(UnableToInterpolateDataSourceURLError())).eraseToAnyPublisher()
        }
    }

    @MainActor
    private func refresh() async {
        fetchedData = nil
    }

    private func setupRefreshTimerIfNeeded() -> Timer? {
        guard let pollInterval = dataSource.pollInterval, refreshTimer == nil else {
            return nil
        }

        return Timer.scheduledTimer(withTimeInterval: TimeInterval(pollInterval), repeats: true) { _ in
            Task {
                await refresh()
            }
        }
    }
}

private extension URLSession {
    func dataPublisher(for request: URLRequest) -> AnyPublisher<Result<Any?, Error>, Never> {
        dataTaskPublisher(for: request)
            .retry(1)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                return element.data
            }
            .tryMap { data in
                try JSONSerialization.jsonObject(with: data)
            }
            .map { data in
                .success(data)
            }
            .catch { error in
                Just(.failure(error)).eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

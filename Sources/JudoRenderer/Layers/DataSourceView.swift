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
import JudoModel
import SwiftUI

struct DataSourceView: SwiftUI.View {
    @Environment(\.data) private var data
    @Environment(\.properties) private var properties
    @State private var fetchedData: Any?
    @State private var refreshTimer: Timer?

    @ObservedObject var dataSource: DataSource

    var body: some SwiftUI.View {
        if fetchedData == nil {
            layersView
                .environment(\.data, fetchedData)
                .onReceive(dataPublisher) { result in
                    guard case let Result.success(fetchedData) = result else {
                        return
                    }

                    self.fetchedData = fetchedData
                }
        } else {
            if #available(iOS 15.0, *) {
                layersView
                    .environment(\.data, fetchedData)
                    .refreshable {
                        await refresh()
                    }
            } else {
                layersView
                    .environment(\.data, fetchedData)
            }
        }
    }

    private var layersView: some SwiftUI.View {
        ForEach(dataSource.children.allOf(type: Layer.self)) {
            LayerView(layer: $0)
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
            let request = try dataSource.urlRequest(data: data, properties: properties)
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

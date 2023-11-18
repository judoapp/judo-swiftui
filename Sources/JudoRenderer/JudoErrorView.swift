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

import SwiftUI

public struct JudoErrorView: View {
    private var error: JudoError
    
    public init(_ error: JudoError) {
        self.error = error
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
            
            VStack(spacing: 0) {
                if let logo {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } else {
                    Text("Judo")
                        .font(.system(.title2))
                        .bold()
                        .foregroundColor(.purple)
                        .frame(height: 40)
                }
                
                Text("\(statusCode)").bold()
                
                Text(description).font(.system(.footnote))
            }
        }
        .frame(width: 100, height: 100)
    }
    
    private var logo: UIImage? {
        guard let path = Bundle.module.path(forResource: "Logo", ofType: "png") else {
            return nil
        }

        return UIImage(contentsOfFile: path)
    }
    
    private var statusCode: Int {
        switch error {
        case .fileNotFound:
            return 404
        case .emptyFile:
            return 204
        case .dataCorrupted:
            return 500
        case .downloadFailed(let statusCode, _):
            return statusCode
        }
    }
    
    private var description: String {
        switch error {
        case .fileNotFound:
            return "Not Found"
        case .emptyFile:
            return "Empty File"
        case .dataCorrupted:
            return "Invalid File"
        case .downloadFailed:
            return "Download Failed"
        }
    }
}

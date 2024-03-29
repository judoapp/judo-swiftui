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

import Foundation

struct LegacyCanvasPreview: Decodable {
    struct Frame: Decodable, Hashable {
        static let device = Frame(width: 375, height: nil, deviceBezels: true)
        static let vertical = Frame(width: 375, height: nil, deviceBezels: false)
        
        var width: CGFloat?
        var height: CGFloat?
        var deviceBezels: Bool

        init(width: CGFloat?, height: CGFloat?, deviceBezels: Bool) {
            self.width = width
            self.height = height
            self.deviceBezels = deviceBezels
        }
    }

    var frame: Frame

    init(frame: Frame) {
        self.frame = frame
    }

    // MARK: Codable

    private enum CodingKeys: CodingKey {
        case frame

        // Legacy
        case width
        case height
        case simulateDevice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let meta = decoder.userInfo[.meta] as! Meta
        switch meta.version {
        case ..<14:
            let width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
            let height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
            let simulateDevice = try container.decode(Bool.self, forKey: .simulateDevice)

            frame = Frame(
                width: width,
                height: height,
                deviceBezels: simulateDevice
            )

        default:
            frame = try container.decode(Frame.self, forKey: .frame)
        }
    }
}

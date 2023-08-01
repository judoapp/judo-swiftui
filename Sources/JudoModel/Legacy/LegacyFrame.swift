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

struct LegacyFrame: Decodable {
    var width: CGFloat?
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var height: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?
    var alignment: Alignment
    
    private enum CodingKeys: String, CodingKey {
        case width
        case minWidth
        case maxWidth
        case height
        case minHeight
        case maxHeight
        case alignment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        minWidth = try container.decodeIfPresent(CGFloat.self, forKey: .minWidth)
        maxWidth = try container.decodeIfPresent(CGFloat.self, forKey: .maxWidth)
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
        minHeight = try container.decodeIfPresent(CGFloat.self, forKey: .minHeight)
        maxHeight = try container.decodeIfPresent(CGFloat.self, forKey: .maxHeight)
        alignment = try container.decodeIfPresent(Alignment.self, forKey: .alignment) ?? .center
    }
}

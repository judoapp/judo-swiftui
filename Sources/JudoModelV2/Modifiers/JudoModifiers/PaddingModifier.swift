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

public class PaddingModifier: JudoModifier {

    @Published public var padding: Padding = Padding(0)
    @Published public var advanced: Bool = false {
        didSet {
            if !advanced {
                var padding = padding
                padding.leading = padding.trailing
                padding.bottom = padding.top
                self.padding = padding
            }
        }
    }

    public required init() {
        super.init()
    }

    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! PaddingModifier
        modifier.padding = padding
        modifier.advanced = advanced
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case padding
        case advanced
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        padding = try container.decode(Padding.self, forKey: .padding)
        advanced = try container.decode(Bool.self, forKey: .advanced)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(padding, forKey: .padding)
        try container.encode(advanced, forKey: .advanced)
        try super.encode(to: encoder)
    }
}

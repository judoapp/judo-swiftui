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

import CoreGraphics
import SwiftUI

public class Layer: Node {
    @objc public dynamic var isLocked = false { willSet { objectWillChange.send() } }
    
    public required init() {
        super.init()
    }
    
    // MARK: Applicable Actions
    
    override public var applicableActions: ApplicableActions {
        var actions: ApplicableActions = [
            .cut,
            .copy,
            .paste,
            .pasteOver,
            .delete,
            .embedInStack,
            .lock,
            .move
        ]
        
        if let parent = parent, parent.canAcceptChild(ofType: Spacer.self) {
            actions.insert(.addSpacer)
        }
        
        return actions
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let layer = super.copy(with: zone) as! Layer
        layer.isLocked = isLocked
        return layer
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case isLocked
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isLocked = try container.decode(Bool.self, forKey: .isLocked)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isLocked, forKey: .isLocked)
        try super.encode(to: encoder)
    }
}

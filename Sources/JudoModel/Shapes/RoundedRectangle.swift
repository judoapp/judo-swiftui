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

public final class RoundedRectangle: Shape {
    public override class var humanName: String {
        "Rounded Rectangle"
    }
    
    @Published public var cornerRadius: Variable<Double> = 8
    @Published public var cornerStyle = RoundedCornerStyle.circular

    required public init() {
        super.init()
    }
    
    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        updateVariable(\.cornerRadius, properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let roundedRectangle = super.copy(with: zone) as! RoundedRectangle
        roundedRectangle.cornerRadius = cornerRadius
        roundedRectangle.cornerStyle = cornerStyle
        return roundedRectangle
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case cornerRadius
        case cornerStyle
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

        switch coordinator.documentVersion {
        case ..<17:
            cornerRadius = try Variable(container.decode(Double.self, forKey: .cornerRadius))
        default:
            cornerRadius = try container.decode(Variable<Double>.self, forKey: .cornerRadius)
        }

        cornerStyle = try container.decode(RoundedCornerStyle.self, forKey: .cornerStyle)
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cornerRadius, forKey: .cornerRadius)
        try container.encode(cornerStyle, forKey: .cornerStyle)
        try super.encode(to: encoder)
    }
}

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

public class FontModifier: JudoModifier {

    @Published public var font: Font = .dynamic(textStyle: .body, design: .default)

    public required init() {
        super.init()
    }

    // MARK: Variables
    
    public override func updateVariables(properties: MainComponent.Properties, data: Any?, fetchedImage: SwiftUI.Image?, unbind: Bool, undoManager: UndoManager?) {
        switch font {
        case .custom(let fontName, let size):
            var updatedSize = size.withUpdatedConstant(
                properties: properties,
                data: data,
                fetchedImage: fetchedImage
            )
            
            if unbind {
                updatedSize.unbind()
            }
            
            let newValue = Font.custom(fontName: fontName, size: updatedSize)
            set(\.font, to: newValue, undoManager: undoManager)
        case .fixed(let size, let weight, let design):
            var updatedSize = size.withUpdatedConstant(
                properties: properties,
                data: data,
                fetchedImage: fetchedImage
            )
            
            if unbind {
                updatedSize.unbind()
            }
            
            let newValue = Font.fixed(size: updatedSize, weight: weight, design: design)
            set(\.font, to: newValue, undoManager: undoManager)
        default:
            break
        }
        
        super.updateVariables(properties: properties, data: data, fetchedImage: fetchedImage, unbind: unbind, undoManager: undoManager)
    }
    
    // MARK: NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        let modifier = super.copy(with: zone) as! FontModifier
        modifier.font = font
        return modifier
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case font
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        font = try container.decode(Font.self, forKey: .font)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(font, forKey: .font)
        try super.encode(to: encoder)
    }
}

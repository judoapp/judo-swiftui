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

extension KeyedDecodingContainer {
    func decodeActions(forKey key: K) throws -> [Action] {
        try decode([ActionWrapper].self, forKey: key).compactMap(\.action)
    }
}

private struct ActionWrapper: Decodable {
    let action: Action?
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .typeName)
        
        switch typeName {
        case DismissAction.typeName:
            action = try DismissAction(from: decoder)
        case OpenURLAction.typeName:
            action = try OpenURLAction(from: decoder)
        case RefreshAction.typeName:
            action = try RefreshAction(from: decoder)
            
        // Property Actions
        case SetPropertyAction.typeName:
            action = try SetPropertyAction(from: decoder)
        case TogglePropertyAction.typeName:
            action = try TogglePropertyAction(from: decoder)
        case IncrementPropertyAction.typeName:
            action = try IncrementPropertyAction(from: decoder)
        case DecrementPropertyAction.typeName:
            action = try DecrementPropertyAction(from: decoder)
            
        // Custom
        case CustomAction.typeName:
            action = try CustomAction(from: decoder)
            
        default:
            throw DecodingError.typeMismatch(
                Action.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown action type: \(typeName)",
                    underlyingError: nil
                )
            )
        }
    }
}

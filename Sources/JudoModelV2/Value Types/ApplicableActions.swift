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
import SwiftUI

/// A set of all actions that are currently applicable to an object.
///
/// Provides a means for doing a "lowest common denominator" approach to establishing agreement between multiple actors (such as multiple selected layers) what actions maybe legally performed. This other than layers -- such as current pasteboard contents -- may participate.
public struct ApplicableActions: OptionSet {
    public static let none = ApplicableActions([])
    public static var all = ApplicableActions(rawValue: ~0)
    
    public static let cut = ApplicableActions(rawValue: 1 << 0)
    public static let copy = ApplicableActions(rawValue: 1 << 1)
    public static let paste = ApplicableActions(rawValue: 1 << 2)
    public static let delete = ApplicableActions(rawValue: 1 << 3)
    public static let pasteOver = ApplicableActions(rawValue: 1 << 4)
    public static let embedInStack = ApplicableActions(rawValue: 1 << 5)
    public static let lock = ApplicableActions(rawValue: 1 << 6)
    public static let addSpacer = ApplicableActions(rawValue: 1 << 8)
    public static let move = ApplicableActions(rawValue: 1 << 9)
    public static let useAsModifier = ApplicableActions(rawValue: 1 << 10)

    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension ApplicableActions: CustomDebugStringConvertible {
    public var debugDescription: String {
        var options: [String] = []

        if self.contains(.all) {
            options += ["all"]
        } else if self.contains(.paste) {
            options += ["paste"]
        } else if self.contains(.copy) {
            options += ["copy"]
        } else if self.contains(.pasteOver) {
            options += ["pasteOver"]
        } else if self.contains(.move) {
            options += ["drag"]
        } else if self.contains(.addSpacer) {
            options += ["addSpacer"]
        } else if self.contains(.embedInStack) {
            options += ["embedInStack"]
        } else if self.contains(.lock) {
            options += ["lock"]
        } else if self.contains(.useAsModifier) {
            options += ["useAsModifier"]
        }
      
        return "rawValue: \(rawValue), contains: [" + options.joined(separator: ",") + "]"
    }
}

extension Swift.Collection where Element: Layer {
    public var applicableActions: ApplicableActions {
        if isEmpty {
            return .none
        }
        
        let allActions = map { $0.applicableActions }
        return allActions.reduce(.all) { (result, layerApplicableActions) in
            ApplicableActions(rawValue: result.rawValue & layerApplicableActions.rawValue)
        }
    }
}

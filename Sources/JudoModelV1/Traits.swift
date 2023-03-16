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

public struct Traits: OptionSet {
    public static let none = Traits([])
    
    /// Indicates the node can be inset from the safe area of the screen.
    public static let insettable = Traits(rawValue: 1 << 0)
    
    /// Indicates the node will resize itself to fill the frame proposed to it.
    public static let resizable = Traits(rawValue: 1 << 1)
    
    /// Indicates the node can have padding applied to it.
    public static let paddable = Traits(rawValue: 1 << 2)
    
    /// Indicates the node can have a frame applied to it.
    public static let frameable = Traits(rawValue: 1 << 3)
    
    /// Indicates the node can be embedded in a HStack, VStack or ZStack.
    public static let stackable = Traits(rawValue: 1 << 4)
    
    /// Indicates the node can have an offset defined.
    public static let offsetable = Traits(rawValue: 1 << 5)
    
    /// Indicates the node can have shadows applied to it.
    public static let shadowable = Traits(rawValue: 1 << 6)
    
    /// Indicates the node can have its opacity adjusted.
    public static let fadeable = Traits(rawValue: 1 << 7)
    
    /// Indicates the node can have a background behind it and/or an overlay/mask on top of it.
    public static let layerable = Traits(rawValue: 1 << 8)
    
    /// Indicates the node can have an action assigned to it which makes the node behave like a button.
    public static let actionable = Traits(rawValue: 1 << 9)
    
    /// Indicates the node for which Accessibility settings can be customized.
    public static let accessible = Traits(rawValue: 1 << 10)
    
    /// Indicates the node has properties which can be overridden by a data source.
    public static let overridable = Traits(rawValue: 1 << 11)
    
    /// Indicates the node can have metadata set.
    public static let metadatable = Traits(rawValue: 1 << 12)
    
    /// Indicates the node is not compatible with iOS.
    public static let iosIncompatible = Traits(rawValue: 1 << 13)
    
    /// Indicates the node is not compatible with Android.
    public static let androidIncompatible = Traits(rawValue: 1 << 14)

    /// Indicates the node can have code preview option available.
    public static let codePreview = Traits(rawValue: 1 << 15)

    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

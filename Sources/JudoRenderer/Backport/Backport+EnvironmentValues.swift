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
import Backport

fileprivate extension BackportNamespace {

    // @available(iOS, deprecated: 15.0, message: "We should update the BoldModifier so that it now longer uses this workaround")
    struct BoldModifierEnvironmentKey: EnvironmentKey {
        static var defaultValue: Bool = false
    }

    // @available(iOS, deprecated: 15.0, message: "We should update the ItalicModifier so that it now longer uses this workaround")
    struct ItalicModifierEnvironmentKey: EnvironmentKey {
        static var defaultValue: Bool = false
    }

    // @available(iOS, deprecated: 16.0, message: "We should update the UnderlineModifier so that it now longer uses this workaround")
    struct UnderlineModifierEnvironmentKey: EnvironmentKey {
        static var defaultValue: (isActive: Bool, color: Color?) = (false, nil)
    }
}

extension EnvironmentValues {

    /// isBold is used as part of the modifier chain.
    ///
    /// `.bold()` can only be applied to `SwiftUI.Text`s on macOS 12 or less.
    /// Where as on macOS 13+ it can be applied to a `SwiftUI.View`.
    /// This work around ensures that we can apply bold.
    // @available(iOS, deprecated: 15.0, message: "We should update the BoldModifier so that it no longer uses this workaround")
    var isBold: Bool {
        get { self[BackportNamespace.BoldModifierEnvironmentKey.self] }
        set { self[BackportNamespace.BoldModifierEnvironmentKey.self] = newValue }
    }

    /// isItalic is used as part of the modifier chain.
    ///
    /// `.italic()` can only be applied to `SwiftUI.Text`s on macOS 12 or less.
    /// Where as on macOS 13+ it can be applied to a `SwiftUI.View`.
    /// This work around ensures that we can apply italic.
    // @available(iOS, deprecated: 15.0, message: "We should update the ItalicModifier so that it now longer uses this workaround")
    var isItalic: Bool {
        get { self[BackportNamespace.ItalicModifierEnvironmentKey.self] }
        set { self[BackportNamespace.ItalicModifierEnvironmentKey.self] = newValue }
    }

    var isUnderlined: (isActive: Bool, color: Color?) {
        get { self[BackportNamespace.UnderlineModifierEnvironmentKey.self] }
        set { self[BackportNamespace.UnderlineModifierEnvironmentKey.self] = newValue }
    }
}

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
import JudoDocument

private struct AssetManagerKey: EnvironmentKey {
    static var defaultValue = AssetManager()
}

private struct ActionHandlersKey: EnvironmentKey {
    static var defaultValue: [ActionName: ActionHandler] = [:]
}

private struct DataKey: EnvironmentKey {
    static var defaultValue: Any?
}

private struct DocumentKey: EnvironmentKey {
    static var defaultValue = DocumentNode()
}

private struct FetchedImageKey: EnvironmentKey {
    static var defaultValue: SwiftUI.Image?
}

private struct ComponentBindingsKey: EnvironmentKey {
    static var defaultValue = ComponentBindings()
}

extension EnvironmentValues {
    var assetManager: AssetManager {
        get { self[AssetManagerKey.self] }
        set { self[AssetManagerKey.self] = newValue }
    }
    
    var actionHandlers: [ActionName: ActionHandler] {
        get { self[ActionHandlersKey.self] }
        set { self[ActionHandlersKey.self] = newValue }
    }
    
    var data: Any? {
        get { self[DataKey.self] }
        set { self[DataKey.self] = newValue }
    }
    
    var document: DocumentNode {
        get { self[DocumentKey.self] }
        set { self[DocumentKey.self] = newValue }
    }
    
    var fetchedImage: SwiftUI.Image? {
        get { self[FetchedImageKey.self] }
        set { self[FetchedImageKey.self] = newValue }
    }

    var componentBindings: ComponentBindings {
        get { self[ComponentBindingsKey.self] }
        set { self[ComponentBindingsKey.self] = newValue }
    }
}

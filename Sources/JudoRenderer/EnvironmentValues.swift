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
import JudoModel

private struct NavigationControllerEnvironmentKey: EnvironmentKey {
    static var defaultValue: UINavigationController?
}

private struct ComponentPropertiesKey: EnvironmentKey {
    static var defaultValue = MainComponent.Properties()
}

private struct CustomActionsKey: EnvironmentKey {
    static var defaultValue: [CustomActionIdentifier: ActionHandler<UserInfo>] = [:]
}

private struct DataKey: EnvironmentKey {
    static var defaultValue: Any?
}

private struct FetchedImageKey: EnvironmentKey {
    static var defaultValue: SwiftUI.Image?
}

extension EnvironmentValues {

    var properties: MainComponent.Properties {
        get { self[ComponentPropertiesKey.self] }
        set { self[ComponentPropertiesKey.self] = newValue }
    }

    var customActions: [CustomActionIdentifier: ActionHandler<UserInfo>] {
        get { self[CustomActionsKey.self] }
        set { self[CustomActionsKey.self] = newValue }
    }

    var data: Any? {
        get { self[DataKey.self] }
        set { self[DataKey.self] = newValue }
    }
    
    var fetchedImage: SwiftUI.Image? {
        get { self[FetchedImageKey.self] }
        set { self[FetchedImageKey.self] = newValue }
    }

    var navigationController: UINavigationController? {
        get { self[NavigationControllerEnvironmentKey.self] }
        set { self[NavigationControllerEnvironmentKey.self] = newValue }
    }

}

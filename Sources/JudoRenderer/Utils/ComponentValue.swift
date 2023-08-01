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
import Foundation
import JudoModel

/// Resolve wrapped value in the context of the view component state properties
@propertyWrapper struct ComponentValue<WrappedValue, ProjectedValue>: DynamicProperty where WrappedValue: ResolvableComponentValue<ProjectedValue> {
    @EnvironmentObject private var componentState: ComponentState
    @EnvironmentObject private var localizations: DocumentLocalizations
    @Environment(\.data) private var data

    var wrappedValue: WrappedValue
    var projectedValue: ProjectedValue {
        wrappedValue.resolve(data: data, componentState: componentState)
    }
}

@propertyWrapper struct OptionalComponentValue<WrappedValue, ProjectedValue>: DynamicProperty where WrappedValue: ResolvableComponentValue<ProjectedValue?> {
     @EnvironmentObject private var componentState: ComponentState
     @EnvironmentObject private var localizations: DocumentLocalizations
     @Environment(\.data) private var data

     var wrappedValue: WrappedValue?
     var projectedValue: ProjectedValue? {
         wrappedValue?.resolve(data: data, componentState: componentState)
     }
 }

protocol ResolvableComponentValue<T> {
    associatedtype T
    func resolve(data: Any?, componentState: ComponentState) -> T
}

extension TextValue: ResolvableComponentValue {


    func resolve(data: Any?, componentState: ComponentState) -> String? {

        switch self {
        case .literal(let key):
            return key
        case .verbatim(let content):
            return content
        case .property(let name, _):
            switch componentState.properties[name] {
            case .text(let value):
                return value
            case .number(let number):
                return number.description
            case .boolean, .component, .image, .none:
                return nil
            }

        case .data(let keyPath):
            let value = JSONSerialization.value(
                forKeyPath: keyPath,
                data: data,
                properties: componentState.properties
            )

            switch value {
            case let string as NSString:
                return string as String
            case let number as NSNumber:
                return number.doubleValue.description
            default:
                return nil
            }
        }
    }

}

extension BooleanValue: ResolvableComponentValue {

    func resolve(data: Any?, componentState: ComponentState) -> Bool? {
        switch self {
        case .constant(let value):
            return value
        case .property(let name):
            if case .boolean(let value) = componentState.properties[name] {
                return value
            }
            return nil
        case .data(let keyPath):
            let value = JSONSerialization.value(
                forKeyPath: keyPath,
                data: data,
                properties: componentState.properties
            )
            switch value {
            case let bool as Bool:
                return bool
            case let number as NSNumber:
                return number.boolValue
            default:
                return nil
            }
        }
    }

}

extension NumberValue: ResolvableComponentValue {

    func resolve(data: Any?, componentState: ComponentState) -> Double? {
        switch self {
        case .constant(value: let value):
            return value
        case .property(name: let name):
            if case .number(let value) = componentState.properties[name] {
                return value
            }
            return nil
        case .data(keyPath: let keyPath):
            let value = JSONSerialization.value(forKeyPath: keyPath, data: data, properties: componentState.properties)
            switch value {
            case let number as NSNumber:
                return number.doubleValue
            default:
                return nil
            }
        }
    }


}

extension ImageValue: ResolvableComponentValue {

    func resolve(data: Any?, componentState: ComponentState) -> ImageReference? {
        switch self {
        case .property(let name):
            if case .image(let value) = componentState.properties[name] {
                return value
            }
            return nil
        case .reference(imageReference: let imageReference):
            return imageReference
        case .fetchedImage:
            return nil
        }
    }

}

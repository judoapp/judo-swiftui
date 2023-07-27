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

import Combine
import SwiftUI

@propertyWrapper
public struct Dependent<Value> where Value: Dependable {
    private var cancellables = [AnyCancellable]()
    
    weak var publisher: ObservableObjectPublisher? {
        didSet {
            observeObject()
        }
    }
    
    public var wrappedValue: Value {
        willSet {
            publisher?.send()
        }
        
        didSet {
            observeObject()
        }
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    private mutating func observeObject() {
        let upstream = publisher
        cancellables = wrappedValue.publishers.map { [weak upstream] downstream in
            downstream.sink { _ in
                upstream?.send()
            }
        }
    }
}

// MARK: Dependable

public protocol Dependable {
    associatedtype Object: ObservableObject
    
    var publishers: [Object.ObjectWillChangePublisher] { get }
}

extension ObservableObject where Self: Dependable {
    public typealias Object = Self
    
    public var publishers: [Self.ObjectWillChangePublisher] {
        [objectWillChange]
    }
}

extension Array: Dependable where Element: ObservableObject, Element: Dependable {
    public typealias Object = Element
    
    public var publishers: [Element.ObjectWillChangePublisher] {
        map { $0.objectWillChange }
    }
}

extension Set: Dependable where Element: ObservableObject, Element: Dependable {
    public typealias Object = Element
    
    public var publishers: [Element.ObjectWillChangePublisher] {
        map { $0.objectWillChange }
    }
}

extension Optional: Dependable where Wrapped: ObservableObject, Wrapped: Dependable {
    public typealias Object = Wrapped
    
    public var publishers: [Wrapped.ObjectWillChangePublisher] {
        map { $0.publishers } ?? []
    }
}

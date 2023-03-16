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

public protocol UndoableObject: AnyObject {
    
}

extension UndoableObject {
    public func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, to newValue: Value, undoManager: UndoManager?) {
        let oldValue = self[keyPath: keyPath]
        self[keyPath: keyPath] = newValue
        
        undoManager?.registerUndo(withTarget: self) { [unowned undoManager] in
            $0.set(keyPath, to: oldValue, undoManager: undoManager)
        }
    }
}

extension Node: UndoableObject {}

extension ColorReference: UndoableObject {}

extension DocumentColor: UndoableObject {}

extension DocumentGradient: UndoableObject {}

extension DocumentLocalizations: UndoableObject {}

extension Segue: UndoableObject {}

extension DocumentData: UndoableObject {}

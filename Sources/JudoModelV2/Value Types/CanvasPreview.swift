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

public struct CanvasPreview: Codable, Hashable {
    public enum Layout {
        case device
        case vertical
        case horizontal
        case fixed
        case none
    }
    
    public var width: CGFloat?
    public var height: CGFloat?
    public var simulateDevice: Bool
    
    public init(width: CGFloat?, height: CGFloat?, simulateDevice: Bool) {
        self.width = width
        self.height = height
        self.simulateDevice = simulateDevice
    }
    
    public init(layout: Layout) {
        switch layout {
        case .device:
            self.init(
                width: 375,
                height: nil,
                simulateDevice: true
            )
        case .vertical:
            self.init(
                width: 375,
                height: nil,
                simulateDevice: false
            )
        case .horizontal:
            self.init(
                width: nil,
                height: 200,
                simulateDevice: false
            )
        case .fixed:
            self.init(
                width: 200,
                height: 200,
                simulateDevice: false
            )
        case .none:
            self.init(
                width: nil,
                height: nil,
                simulateDevice: false
            )
        }
    }
    
    public var layout: Layout {
        get {
            if simulateDevice {
                return .device
            }
            
            switch (width, height) {
            case (.some, .some):
                return .fixed
            case (.some, .none):
                return .vertical
            case (.none, .some):
                return .horizontal
            case (.none, .none):
                return .none
            }
        }
        
        set {
            switch newValue {
            case .device:
                simulateDevice = true
            case .vertical:
                width = width ?? 375
                height = nil
                simulateDevice = false
            case .horizontal:
                width = nil
                height = height ?? 200
                simulateDevice = false
            case .fixed:
                width = width ?? 200
                height = height ?? 200
                simulateDevice = false
            case .none:
                width = nil
                height = nil
                simulateDevice = false
            }
        }
    }
}

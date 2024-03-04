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
import CoreGraphics

public struct Device: Codable, Hashable {
    public enum Model: String, Codable, Hashable {
        case iPhone15ProMax
        case iPhone14
        case iPadPro11Inch
    }
    
    public enum Orientation: String, Codable, Hashable {
        case portrait
        case landscape
    }
    
    public enum UserInterfaceIdiom {
        case phone
        case pad
    }
    
    public var model: Model
    public var orientation: Orientation
    
    public var userInterfaceIdiom: UserInterfaceIdiom {
        switch model {
        case .iPhone15ProMax:
            return .phone
        case .iPhone14:
            return .phone
        case .iPadPro11Inch:
            return .pad
        }
    }
    
    public init() {
        model = .iPhone14
        orientation = .portrait
    }
    
    public init(model: Model, orientation: Orientation) {
        self.model = model
        self.orientation = orientation
    }
}

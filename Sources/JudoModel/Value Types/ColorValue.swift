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
import SwiftUI

public struct ColorValue: Equatable, Codable, Hashable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(rgbHex: String) {
        let rgb = rgbHex.filter { $0 != "#" }
        guard let rgba = Int(rgb, radix: 16) else {
            red = 1
            green = 1
            blue = 1
            alpha = 1
            return
        }
        if rgbHex.count >= 8 {
            let red = ((0xff << 24) & rgba) >> 24
            let green = ((0xff << 16) & rgba) >> 16
            let blue = ((0xff << 8) & rgba) >> 8
            let alpha = 0xff & rgba
            self.red = Double(red) / 255
            self.green = Double(green) / 255
            self.blue = Double(blue) / 255
            self.alpha = Double(alpha) / 255
        } else {
            let red = ((0xff << 16) & rgba) >> 16
            let green = ((0xff << 8) & rgba) >> 8
            let blue = (0xff & rgba) >> 0
            self.red = Double(red) / 255
            self.green = Double(green) / 255
            self.blue = Double(blue) / 255
            self.alpha = 1.0
        }
    }
    
    public var color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func hexRepresentation(withAlpha: Bool = false) -> String {
        let redInt = Int(round(red * 255))
        let greenInt = Int(round(green * 255))
        let blueInt = Int(round(blue * 255))
        let alphaInt = Int(round(alpha * 255))
        if withAlpha {
            let rgba = alphaInt +
                blueInt << 8 +
                greenInt << 16 +
                redInt << 24
            return String(format:"%08X", rgba)
        } else {
            let rgb = blueInt +
                greenInt << 8 +
                redInt << 16
            return String(format:"%06X", rgb)
        }
    }
    
    // MARK: Constants
    
    public static var clear: ColorValue {
        return ColorValue(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    public static var white: ColorValue {
        return ColorValue(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    public static var red: ColorValue {
        return ColorValue(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    /// A stand-in value that indicates (in-band, rather than using an optional) that this color has been likely not set by the user.
    public static var notSet: ColorValue {
        return ColorValue(red: 1, green: 0, blue: 0, alpha: 0)
    }
}

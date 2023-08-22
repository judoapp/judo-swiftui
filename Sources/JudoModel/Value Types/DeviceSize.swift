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

public enum DeviceSize: String, CaseIterable, Codable, Equatable {
    case small
    case medium
    case large
    case tablet

    public var cgSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 320, height: 568)
        case .medium:
            return CGSize(width: 375, height: 812)
        case .large:
            return CGSize(width: 428, height: 926)
        case .tablet:
            return CGSize(width: 820, height: 1180)
        }
    }
    
    public var width: CGFloat {
        cgSize.width
    }
    
    public var height: CGFloat {
        cgSize.height
    }
    
    public var name: String {
        switch self {
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        case .tablet:
            return "Tablet"
        }
    }
    
    public var tag: Int {
        switch self {
        case .small:
            return 1
        case .medium:
            return 2
        case .large:
            return 3
        case .tablet:
            return 14
        }
    }

}

extension DeviceSize {
    public var deviceWidth: CGFloat {
        switch self {
        case .small, .medium: return 390
        case .large: return 430
        case .tablet: return 834
        }
    }

    public var deviceHeight: CGFloat {
        switch self {
        case .small, .medium: return 844
        case .large: return 932
        case .tablet: return 1194
        }
    }
}

extension DeviceSize: Comparable {
    public static func < (lhs: DeviceSize, rhs: DeviceSize) -> Bool {
        lhs.height < rhs.height && lhs.width < rhs.width
    }
}

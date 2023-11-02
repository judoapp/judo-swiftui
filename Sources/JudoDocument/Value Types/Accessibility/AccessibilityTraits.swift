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

public struct AccessibilityTraits: OptionSet, Codable, Hashable {
    public static let isButton = AccessibilityTraits(rawValue: 1 << 0)
    public static let isHeader = AccessibilityTraits(rawValue: 1 << 1)
    public static let isLink = AccessibilityTraits(rawValue: 1 << 2)
    public static let isModal = AccessibilityTraits(rawValue: 1 << 3)
    public static let isSummaryElement = AccessibilityTraits(rawValue: 1 << 4)
    public static let startsMediaSession = AccessibilityTraits(rawValue: 1 << 5)

    public static let none: AccessibilityTraits = []
    public static let all: AccessibilityTraits = [.isButton, .isHeader, .isLink, .isModal, .isSummaryElement, .startsMediaSession]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

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

public struct PreviewSettings: Codable, Hashable {
    public var device: Device?
    public var isDarkModeEnabled: Bool
    public var isHighContrastModeEnabled: Bool
    public var contentSizeCategory: ContentSizeCategory?
    public var previewLanguage: PreviewLanguage?
    
    public init() {
        device = Device()
        isDarkModeEnabled = false
        isHighContrastModeEnabled = false
        contentSizeCategory = nil
        previewLanguage = nil
    }
    
    public init(device: Device?, isDarkModeEnabled: Bool, isHighContrastModeEnabled: Bool, contentSizeCategory: ContentSizeCategory?, previewLanguage: PreviewLanguage?) {
        self.device = device
        self.isDarkModeEnabled = isDarkModeEnabled
        self.isHighContrastModeEnabled = isHighContrastModeEnabled
        self.contentSizeCategory = contentSizeCategory
        self.previewLanguage = previewLanguage
    }
}

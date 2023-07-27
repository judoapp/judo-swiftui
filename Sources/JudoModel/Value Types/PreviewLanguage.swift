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

/// Maps to BCP-47 codes supported by the Google Translate API.
public enum PreviewLanguage: String, Codable, CaseIterable, CustomStringConvertible {
    case english = "en"
    case arabic = "ar"
    case french = "fr"
    case german = "de"
    case hebrew = "he"
    case hindi = "hi"
    case japanese = "ja"
    case korean = "ko"
    case spanish = "es"
    case polish = "pl"
    case simplifiedChinese = "zh-CN"
    case traditionalChinese = "zh-TW"

    public var description: String {
        switch self {
            case .english:
                return "English"
            case .arabic:
                return "Arabic"
            case .french:
                return "French"
            case .german:
                return "German"
            case .hebrew:
                return "Hebrew"
            case .hindi:
                return "Hindi"
            case .japanese:
                return "Japanese"
            case .korean:
                return "Korean"
            case .spanish:
                return "Spanish"
            case .polish:
                return "Polish"
            case .simplifiedChinese:
                return "Chinese (Simplified)"
            case .traditionalChinese:
                return "Chinese (Traditional)"
        }
    }

    public var locale: Locale {
        Locale(identifier: rawValue)
    }
}

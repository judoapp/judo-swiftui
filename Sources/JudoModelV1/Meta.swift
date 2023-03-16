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

public struct Meta: Codable {
    public var version: Int
    public var compatibilityVersion: Int
    public var appVersion: String
    public var build: String

    public init(version: Int, compatibilityVersion: Int, appVersion: String, build: String) {
        self.version = version
        self.compatibilityVersion = compatibilityVersion
        self.appVersion = appVersion
        self.build = build
    }

    enum CodingKeys: CodingKey {
        case version
        case compatibilityVersion
        case appVersion
        case build
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Int.self, forKey: .version)

        if version >= 12 {
            compatibilityVersion = try container.decode(Int.self, forKey: .compatibilityVersion)
        } else {
            compatibilityVersion = version
        }

        appVersion = try container.decode(String.self, forKey: .appVersion)
        build = try container.decode(String.self, forKey: .build)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(compatibilityVersion, forKey: .compatibilityVersion)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(build, forKey: .build)
    }
}

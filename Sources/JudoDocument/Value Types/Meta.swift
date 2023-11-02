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
    /// The document meta data for any content saved by this copy of the app.
    public static var current: Meta {
        Meta(
            version: 18,
            compatibilityVersion: 18,
            appVersion: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
            build: Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        )
    }
    
    public private(set) var version: Int
    public private(set) var compatibilityVersion: Int
    public private(set) var appVersion: String
    public private(set) var build: String

    private init(version: Int, compatibilityVersion: Int, appVersion: String, build: String) {
        self.version = version
        self.compatibilityVersion = compatibilityVersion
        self.appVersion = appVersion
        self.build = build
    }

    private enum CodingKeys: CodingKey {
        case version
        case compatibilityVersion
        case appVersion
        case build
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Int.self, forKey: .version)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        build = try container.decode(String.self, forKey: .build)

        if version >= 12 {
            compatibilityVersion = try container.decode(Int.self, forKey: .compatibilityVersion)

            // This is to ensure that experiences created during the Beta period
            // are updated to have the correct compatibilityVersion
            if appVersion.hasPrefix("2.") && compatibilityVersion < 13 {
                compatibilityVersion = 13
                version = 13
            }
        } else {
            compatibilityVersion = version
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(compatibilityVersion, forKey: .compatibilityVersion)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(build, forKey: .build)
    }
}

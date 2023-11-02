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

public struct SortDescriptor: Codable, Hashable {
    public var keyPath: String
    public var ascending: Bool
    
    public init(keyPath: String, ascending: Bool = true) {
        self.keyPath = keyPath
        self.ascending = ascending
    }
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case keyPath
        case ascending
        
        // Legacy
        case dataKey
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let meta = decoder.userInfo[.meta] as! Meta
        
        if meta.version >= 7 {
            keyPath = try container.decode(String.self, forKey: .keyPath)
        } else {
            let dataKey = try container.decode(String.self, forKey: .dataKey)
            keyPath = "data.\(dataKey)"
        }
        
        ascending = try container.decode(Bool.self, forKey: .ascending)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyPath, forKey: .keyPath)
        try container.encode(ascending, forKey: .ascending)
    }
}

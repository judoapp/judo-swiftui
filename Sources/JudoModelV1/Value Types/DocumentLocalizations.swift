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

public final class DocumentLocalizations: ObservableObject, Codable {
    public typealias StringsTable = [String: String]
    public typealias LocaleIdentifier = String
    public typealias Entries = [LocaleIdentifier: StringsTable]
    
    @Published public var entries: Entries = [:]
    
    public init() { }
    
    public init(entries: [LocaleIdentifier: StringsTable]) {
        self.entries = entries
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        entries = try container.decode([LocaleIdentifier: StringsTable].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(entries)
    }
    
    public func fuzzyMatch(key: String) -> StringsTable? {
        return entries.first { (localeIdentifier, _) in
            localeIdentifier == key || localeIdentifier.starts(with: "\(key)-") || localeIdentifier.starts(with: "\(key)_")
        }?.value
    }
    
    public subscript(key: LocaleIdentifier) -> StringsTable? {
        return entries[key]
    }
}

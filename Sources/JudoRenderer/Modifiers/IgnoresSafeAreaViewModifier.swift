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

import JudoDocument
import SwiftUI

struct IgnoresSafeAreaViewModifier: SwiftUI.ViewModifier {
    var modifier: IgnoresSafeAreaModifier

    func body(content: Content) -> some SwiftUI.View {
        content.ignoresSafeArea(regions, edges: edges)
    }
    
    private var regions: SafeAreaRegions {
        var result = SafeAreaRegions()
        
        if modifier.regions.contains(.container) {
            result.insert(.container)
        }
        
        if modifier.regions.contains(.keyboard) {
            result.insert(.keyboard)
        }
        
        return result
    }
    
    private var edges: SwiftUI.Edge.Set {
        var result = SwiftUI.Edge.Set()
        
        if modifier.edges.contains(.top) {
            result.insert(.top)
        }
        
        if modifier.edges.contains(.bottom) {
            result.insert(.bottom)
        }
        
        if modifier.edges.contains(.leading) {
            result.insert(.leading)
        }
        
        if modifier.edges.contains(.trailing) {
            result.insert(.trailing)
        }
        
        return result
    }
}


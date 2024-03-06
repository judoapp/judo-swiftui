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

extension DocumentNode {
    var components: [MainComponentNode] {
        children.compactMap { $0 as? MainComponentNode }
    }
    
    func component(named componentName: ComponentName) -> MainComponentNode? {
        components.first { $0.name == componentName.rawValue }
    }

    func startPoint(preferring componentName: ComponentName?) -> StartingPoint? {
        if let componentName, let component = component(named: componentName) {
            return .component(component)
        }
        return startingPoint
    }

    var startingPoint: StartingPoint? {
        // Find the first node that can be used as a StartingPoint
        let startingNode = children.first { node in
            switch node {
            case let artboard as ArtboardNode:
                return artboard.isStartingPoint
            case let component as MainComponentNode:
                return component.isStartingPoint
            default:
                return false
            }
        }

        if let startingPoint = getStartingPoint(from: startingNode) {
            return startingPoint
        }

        // Find the first ArtboardNode or MainComponentNode
        guard let first = children.first(where: { $0 is ArtboardNode || $0 is MainComponentNode }) else {
            return nil
        }

        return getStartingPoint(from: first)
    }

    func getStartingPoint(from node: Node?) -> StartingPoint? {
        switch node {
        case let artboard as ArtboardNode:
            return .artboard(artboard)
        case let component as MainComponentNode:
            return .component(component)
        default:
            return nil
        }
    }

    enum StartingPoint {
        case artboard(ArtboardNode)
        case component(MainComponentNode)
    }
}

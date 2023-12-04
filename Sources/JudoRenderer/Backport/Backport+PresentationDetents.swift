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

import Backport
import JudoDocument
import SwiftUI

extension Backport where Wrapped: SwiftUI.View {
    
    /// Presentation detents are only available in SwiftUI in iOS 16+, they were first introduced in UIKit in iOS 15.
    /// It is possible to Backport them so that they are available on iOS 15 in SwiftUI.
    @ViewBuilder
    func presentationDetents(_ detents: [JudoDocument.PresentationDetent]) -> some View {
        if #available(iOS 16, *) {
            wrapped
                .presentationDetents(Set(detents.compactMap({ $0.swiftUIValue })))
        } else if #available(iOS 15, *) {
            wrapped
                .background(Backport<Any>.Representable(detents: detents))
        } else {
            wrapped
        }
    }
}

@available(iOS 16.0, *)
private extension JudoDocument.PresentationDetent {
    var swiftUIValue: SwiftUI.PresentationDetent? {
        switch standardDetent {
        case .medium:
            return .medium
        case .large:
            return .large
        case .none:
            break
        }

        if let fractionValue {
            return .fraction(fractionValue.constant)
        }

        if let heightValue {
            return .height(heightValue.constant)
        }

        return nil
    }
}

@available(iOS 15, *)
private extension Backport<Any> {
    struct Representable: UIViewControllerRepresentable {
        let detents: [JudoDocument.PresentationDetent]

        func makeUIViewController(context: Context) -> Backport.Representable.Controller {
            Controller(detents: detents)
        }

        func updateUIViewController(_ controller: Backport.Representable.Controller, context: Context) {
            controller.update(detents: detents)
        }
    }
}

@available(iOS 15, *)
private extension Backport.Representable {
    final class Controller: UIViewController, UISheetPresentationControllerDelegate {

        var detents: [JudoDocument.PresentationDetent]
        weak var _delegate: UISheetPresentationControllerDelegate?

        init(detents: [JudoDocument.PresentationDetent]) {
            self.detents = detents
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if let controller = parent?.sheetPresentationController {
                if controller.delegate !== self && _delegate == nil {
                    _delegate = controller.delegate
                    controller.delegate = self
                }
            }
            update(detents: detents)
        }

        override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            super.willTransition(to: newCollection, with: coordinator)
            update(detents: detents)
        }

        func update(detents: [JudoDocument.PresentationDetent]) {
            self.detents = detents

            if let controller = parent?.sheetPresentationController {
                controller.animateChanges {
                    controller.detents = detents.compactMap({ detent in
                        switch detent.standardDetent {
                        case .medium:
                            return .medium()
                        case .large:
                            return .large()
                        case .none:
                            break
                        }

                        if let fractionValue = detent.fractionValue {
                            if fractionValue.constant > 0.5 {
                                return .large()
                            } else {
                                return .medium()
                            }
                        }

                        if let heightValue = detent.heightValue {
                            if heightValue.constant > 400 {
                                return .large()
                            } else {
                                return .medium()
                            }
                        }

                        return nil
                    })

                    controller.prefersScrollingExpandsWhenScrolledToEdge = true
                }

                UIView.animate(withDuration: 0.25) {
                    controller.presentingViewController.view?.tintAdjustmentMode = .automatic
                }
            }
        }

        override func responds(to aSelector: Selector!) -> Bool {
            if super.responds(to: aSelector) { return true }
            if _delegate?.responds(to: aSelector) ?? false { return true }
            return false
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) { return self }
            return _delegate
        }
    }
}

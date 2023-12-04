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

import SwiftUI
import Backport

extension Backport where Wrapped: SwiftUI.View {

    @ViewBuilder
    func interactiveDismissDisabled(_ isDisabled: Bool = true) -> some SwiftUI.View {
        if #available(iOS 15.0, *) {
            wrapped
                .interactiveDismissDisabled(isDisabled)
        } else {
            wrapped
                .background(Backport<Any>.Representable(isModal: isDisabled, onAttempt: nil))
        }
    }
}

private extension Backport where Wrapped == Any {
    struct Representable: UIViewControllerRepresentable {
        let isModal: Bool
        let onAttempt: (() -> Void)?

        func makeUIViewController(context: Context) -> Backport.Representable.Controller {
            Controller(isModal: isModal, onAttempt: onAttempt)
        }

        func updateUIViewController(_ controller: Backport.Representable.Controller, context: Context) {
            controller.update(isModal: isModal, onAttempt: onAttempt)
        }
    }
}

private extension Backport.Representable {
    final class Controller: UIViewController, UIAdaptivePresentationControllerDelegate {
        var isModal: Bool
        var onAttempt: (() -> Void)?
        weak var _delegate: UIAdaptivePresentationControllerDelegate?

        init(isModal: Bool, onAttempt: (() -> Void)?) {
            self.isModal = isModal
            self.onAttempt = onAttempt
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if let controller = parent?.presentationController {
                if controller.delegate !== self  && _delegate == nil {
                    _delegate = controller.delegate
                    controller.delegate = self
                }
            }
            update(isModal: isModal, onAttempt: onAttempt)
        }

        func update(isModal: Bool, onAttempt: (() -> Void)?) {
            self.isModal = isModal
            self.onAttempt = onAttempt

            parent?.isModalInPresentation = isModal
        }

        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            onAttempt?()
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            parent?.isModalInPresentation == false
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

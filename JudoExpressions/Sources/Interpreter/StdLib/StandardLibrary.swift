import Foundation

/// Library of standard functions
let standardLibrary = [
    ExpressionFunction("formatted", closure: { caller, _ in
        guard let value = caller as? Double else {
            return caller
        }

        if #available(macOS 12.0, iOS 15.0, *) {
            return value.formatted(.number.precision(.fractionLength(0...2)))
        } else {
            return NumberFormatter.localizedString(from: value as NSNumber, number: .none)
        }
    })
]

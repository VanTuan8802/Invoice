//
//  UIApplication+Keyboard.swift
//  Invoice
//
//  Presenting an alert from a toolbar tap while the keyboard is up can be
//  swallowed by the keyboard dismissal (the first tap only closes the keyboard).
//  Hide the keyboard first, then run the action.
//

import UIKit

extension UIApplication {
    /// Ends editing in the app (hides the keyboard).
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Hides the keyboard, then runs `action` once it has started to go away.
@MainActor
func afterDismissingKeyboard(_ action: @escaping () -> Void) {
    UIApplication.shared.endEditing()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: action)
}

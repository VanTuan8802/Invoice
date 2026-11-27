//
//  MarkAsPaidDialog.swift
//  Invoice
//
//  Invoice/Mark As Paid: payment-method action sheet over the editor.
//

import SwiftUI

extension View {
    /// Presents the payment methods; `onSelect` marks the open invoice paid.
    func markAsPaidDialog(isPresented: Binding<Bool>, onSelect: @escaping (MarkPaidMethod) -> Void) -> some View {
        optionsSheet(isPresented: isPresented) {
            ForEach(MarkPaidMethod.allCases) { method in
                Button(method.title) { onSelect(method) }
            }
        }
    }
}

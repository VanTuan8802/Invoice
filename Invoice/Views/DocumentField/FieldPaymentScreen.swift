//
//  FieldPaymentScreen.swift
//  Invoice
//
//  Invoice/Payment (+ Method Options): amount, method and date of one payment.
//  Works on a draft; "Done" adds it (or updates the existing one) on the
//  document, back discards it.
//

import SwiftUI
import Factory

struct FieldPaymentScreen: View {
    /// The payment to edit; `nil` adds a new one.
    let paymentID: UUID?

    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore

    @State private var draft = Payment(amount: 0, method: nil)
    /// The method as picked in the sheet (keeps "Debit" apart from "Credit" while editing).
    @State private var methodOption: FieldPaymentMethodOption?
    @State private var showsMethods = false
    @State private var showsDatePicker = false
    @State private var didLoad = false

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_payment_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: commit
            )

            List {
                Section {
                    FieldAmountRow(
                        title: R.stringLocalizable.field_amount(),
                        value: $draft.amount,
                        kind: .currency(code: store.currencyCode)
                    )
                    FieldOptionRow(
                        title: R.stringLocalizable.field_payment_method(),
                        value: methodOption?.title ?? R.stringLocalizable.field_payment_select_method(),
                        style: methodOption == nil ? .placeholder : .value
                    ) {
                        showsMethods = true
                    }
                    FieldDateRows(
                        title: R.stringLocalizable.field_date(),
                        date: $draft.date,
                        isExpanded: $showsDatePicker
                    )
                }
            }
            .fieldListStyle()
        }
        .groupedScreenBackground()
        .fieldOptionsDialog(R.stringLocalizable.field_payment_method(), isPresented: $showsMethods) {
            ForEach(FieldPaymentMethodOption.allCases, id: \.self) { option in
                Button(option.title) {
                    methodOption = option
                    draft.method = option.method
                }
            }
        }
        .onAppear(perform: load)
        .onChange(of: editor.document.id) { _ in
            didLoad = false
            load()
        }
        .trackScreen(.fieldPayment)
    }

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        guard let paymentID, let existing = editor.document.payments.first(where: { $0.id == paymentID }) else { return }
        draft = existing
        methodOption = existing.method.map(FieldPaymentMethodOption.init)
    }

    private func commit() {
        if let index = editor.document.payments.firstIndex(where: { $0.id == draft.id }) {
            editor.document.payments[index] = draft
        } else if draft.amount != 0 || draft.method != nil {
            editor.document.payments.append(draft)
        }
        app.navi.pop()
    }
}

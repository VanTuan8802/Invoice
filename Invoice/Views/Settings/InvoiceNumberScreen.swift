//
//  InvoiceNumberScreen.swift
//  Invoice
//
//  Settings/Invoice Number (+ Edited): next invoice / estimate number. Each must
//  contain a letter and a digit; empty keeps the automatic number (placeholder).
//

import SwiftUI
import Factory

struct InvoiceNumberScreen: View {
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.invoiceNumber) private var storedInvoiceNumber = ""
    @AppStorage(SettingsStorage.Key.estimateNumber) private var storedEstimateNumber = ""

    @State private var invoiceNumber = ""
    @State private var estimateNumber = ""
    @State private var didLoad = false

    private var canSave: Bool {
        DocumentNumberRule.isValid(invoiceNumber) && DocumentNumberRule.isValid(estimateNumber)
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_invoice_number(),
                            showBack: true,
                            backAction: { app.navi.pop() }) {
                HeaderTextButton(title: R.stringLocalizable.save(), action: save)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
            }

            Form {
                Section {
                    numberRow(R.stringLocalizable.settings_invoice_number(),
                              placeholder: store.nextNumber(for: .invoice),
                              text: $invoiceNumber)
                    numberRow(R.stringLocalizable.settings_estimate_number(),
                              placeholder: store.nextNumber(for: .estimate),
                              text: $estimateNumber)
                } footer: {
                    Text(R.stringLocalizable.settings_number_hint())
                        .font(.footnote)
                        .foregroundStyle(Color(R.color.color6B6B78))
                        .padding(.leading, -16)
                }
            }
            .settingsFormStyle()
        }
        .groupedScreenBackground()
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            invoiceNumber = storedInvoiceNumber
            estimateNumber = storedEstimateNumber
        }
        .trackScreen(.settingsInvoiceNumber)
    }

    private func numberRow(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                    .lineLimit(1)
                    .layoutPriority(1)
                TextField("", text: text, prompt: settingsPrompt(placeholder))
                    .font(text.wrappedValue.isEmpty ? .subheadline : .body)
                    .foregroundStyle(Color(R.color.color111118))
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }
            if !DocumentNumberRule.isValid(text.wrappedValue) {
                Text(R.stringLocalizable.settings_invalid_data())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.colorFA0000))
            }
        }
        .padding(.vertical, 4)
    }

    private func save() {
        guard canSave else { return }
        storedInvoiceNumber = invoiceNumber.trimmingCharacters(in: .whitespaces)
        storedEstimateNumber = estimateNumber.trimmingCharacters(in: .whitespaces)
        app.navi.pop()
    }
}

#if DEBUG
#Preview {
    InvoiceNumberScreen()
}
#endif

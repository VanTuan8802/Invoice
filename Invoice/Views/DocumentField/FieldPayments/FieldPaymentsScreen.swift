//
//  FieldPaymentsScreen.swift
//  Invoice
//
//  Invoice/Payment/List: document total, the recorded payments (tap to edit,
//  swipe to delete), "Add Payment", amount paid and balance due.
//

import SwiftUI
import Factory

struct FieldPaymentsScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore

    private var document: Document { editor.document }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_payment_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            List {
                Section {
                    summaryRow(R.stringLocalizable.field_payments_total(), amount: document.total)

                    ForEach(document.payments) { payment in
                        Button {
                            app.navi.push(.documentField(.payment(id: payment.id)))
                        } label: {
                            amountRow(payment.date.numericDateText, amount: payment.amount,
                                      color: Color(R.color.color111118))
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        editor.document.payments.remove(atOffsets: offsets)
                    }

                    Button {
                        app.navi.push(.documentField(.payment(id: nil)))
                    } label: {
                        amountRow(R.stringLocalizable.field_payments_add(), amount: 0,
                                  color: Color(R.color.colorA5A5B0))
                    }
                    .buttonStyle(.plain)
                    // Keep the line above (after the last payment), none above "Paid".
                    .listRowSeparator(.hidden, edges: .bottom)

                    summaryRow(R.stringLocalizable.field_payments_paid(), amount: document.paidTotal)

                    amountRow(R.stringLocalizable.field_payments_balance(), amount: document.balance,
                              color: Color(R.color.colorA5A5B0))
                        .listRowSeparator(.hidden)
                }
            }
            .fieldListStyle()
            .environment(\.defaultMinListRowHeight, 44)
        }
        .groupedScreenBackground()
        .trackScreen(.fieldPayments)
    }

    /// Purple "Total" / "Paid" band: Body ink title, Subheadline grey amount.
    private func summaryRow(_ title: String, amount: Decimal) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
            Spacer(minLength: 8)
            Text(amount.currencyText(code: store.currencyCode))
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color6B6B78))
        }
        .listRowBackground(Color(R.color.colorCFC3FF))
        .listRowSeparator(.hidden)
    }

    /// White Subheadline row: leading text, trailing amount.
    private func amountRow(_ title: String, amount: Decimal, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(title)
            Spacer(minLength: 8)
            Text(amount.currencyText(code: store.currencyCode))
        }
        .font(.subheadline)
        .foregroundStyle(color)
        .contentShape(Rectangle())
    }
}

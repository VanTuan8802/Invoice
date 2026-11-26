//
//  FieldDiscountScreen.swift
//  Invoice
//
//  Invoice/Discount (+ Options): discount type (percentage / flat amount / none)
//  and its amount, applied on the document total.
//

import SwiftUI
import Factory

struct FieldDiscountScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore

    @State private var showsOptions = false

    private var discount: DiscountSetting { editor.document.discount }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_discount_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            List {
                Section {
                    FieldOptionRow(title: R.stringLocalizable.field_discount(), value: discount.fieldTitle) {
                        showsOptions = true
                    }
                    FieldAmountRow(
                        title: R.stringLocalizable.field_amount(),
                        value: $editor.document.discount.value,
                        kind: discount.isPercentage ? .percent : .currency(code: store.currencyCode)
                    )
                    // Per-item discounts live on the line items; "None" has no amount.
                    .disabled(discount.mode != .onTotal)
                }
            }
            .fieldListStyle()
        }
        .groupedScreenBackground()
        .fieldOptionsDialog(R.stringLocalizable.field_discount(), isPresented: $showsOptions) {
            ForEach(FieldDiscountOption.allCases, id: \.self) { option in
                Button(option.title) { option.apply(to: &editor.document.discount) }
            }
        }
        .trackScreen(.fieldDiscount)
    }
}

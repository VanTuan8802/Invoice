//
//  FieldTaxScreen.swift
//  Invoice
//
//  Invoice/Tax (+ Options): how tax applies (none / on the total / per item /
//  deducted), its label and rate, and whether prices already include it.
//

import SwiftUI
import Factory

struct FieldTaxScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor

    @State private var extras = FieldDocumentExtras()
    @State private var showsOptions = false

    private var tax: TaxSetting { editor.document.tax }
    private var option: FieldTaxOption { FieldTaxOption(tax) }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_tax_title(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            List {
                Section {
                    FieldOptionRow(title: R.stringLocalizable.field_tax(), value: option.title) {
                        showsOptions = true
                    }
                    Group {
                        FieldTextRow(
                            title: R.stringLocalizable.field_tax_label(),
                            placeholder: R.stringLocalizable.field_tax_title(),
                            text: $editor.document.tax.label
                        )
                        FieldAmountRow(
                            title: R.stringLocalizable.field_tax_rate(),
                            value: $editor.document.tax.ratePercent,
                            kind: .percent
                        )
                    }
                    .disabled(option == .none)
                }

                if option == .onTotal || option == .perItem {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $extras.taxInclusive) {
                                Text(R.stringLocalizable.field_tax_inclusive())
                                    .font(.body)
                                    .foregroundStyle(Color(R.color.color111118))
                            }
                            .tint(Color(R.color.color111118))

                            Text(R.stringLocalizable.field_tax_inclusive_hint())
                                .font(.subheadline)
                                .foregroundStyle(Color(R.color.colorA5A5B0))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .fieldListStyle()
        }
        .groupedScreenBackground()
        .fieldOptionsDialog(R.stringLocalizable.field_tax(), isPresented: $showsOptions) {
            ForEach(FieldTaxOption.allCases, id: \.self) { option in
                Button(option.title) { option.apply(to: &editor.document.tax) }
            }
        }
        .onAppear { extras = .load(for: editor.document.id) }
        .onChange(of: editor.document.id) { id in extras = .load(for: id) }
        .onChange(of: extras) { $0.save(for: editor.document.id) }
        .trackScreen(.fieldTax)
    }
}

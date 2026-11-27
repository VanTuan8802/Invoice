//
//  FieldInfoScreen.swift
//  Invoice
//
//  Invoice/Info (+ Terms Options) and Estimate/Info: number, dates, terms,
//  PO number and the "Repeat" entry to Invoice/Recurring.
//

import SwiftUI
import Factory

struct FieldInfoScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor

    @State private var extras = FieldDocumentExtras()
    @State private var expandedDate: DateRow?
    @State private var showsTerms = false

    private enum DateRow {
        case issue
        case due
    }

    private var isInvoice: Bool { editor.document.kind == .invoice }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: isInvoice ? R.stringLocalizable.field_info_title_invoice()
                                 : R.stringLocalizable.field_info_title_estimate(),
                actionTitle: R.stringLocalizable.common_done(),
                onBack: { app.navi.pop() },
                onAction: { app.navi.pop() }
            )

            List {
                Section {
                    FieldTextRow(
                        title: isInvoice ? R.stringLocalizable.field_invoice_id()
                                         : R.stringLocalizable.field_estimate_id(),
                        text: $editor.document.number
                    )
                    FieldDateRows(
                        title: R.stringLocalizable.field_date(),
                        date: issueDate,
                        isExpanded: isExpanded(.issue)
                    )
                    if isInvoice {
                        FieldOptionRow(
                            title: R.stringLocalizable.field_terms(),
                            value: FieldTermsOption.current(for: editor.document, isNone: extras.termsNone).title
                        ) {
                            showsTerms = true
                        }
                        if !extras.termsNone {
                            FieldDateRows(
                                title: R.stringLocalizable.field_due_date(),
                                date: dueDate,
                                isExpanded: isExpanded(.due)
                            )
                        }
                    }
                    FieldTextRow(
                        title: R.stringLocalizable.field_po_number(),
                        text: $editor.document.poNumber
                    )
                }

                if isInvoice {
                    Section {
                        FieldOptionRow(
                            title: R.stringLocalizable.field_repeat(),
                            value: editor.document.repeatInterval.fieldTitle,
                            style: .secondary,
                            showsChevron: true
                        ) {
                            app.navi.push(.documentField(.recurring))
                        }
                    } footer: {
                        Text(R.stringLocalizable.field_repeat_footer())
                    }
                }
            }
            .fieldListStyle()
        }
        .groupedScreenBackground()
        .fieldOptionsDialog(R.stringLocalizable.field_terms(), isPresented: $showsTerms) {
            ForEach(FieldTermsOption.sheetOptions, id: \.self) { option in
                Button(option.title) { applyTerms(option) }
            }
        }
        .onAppear { extras = .load(for: editor.document.id) }
        .onChange(of: editor.document.id) { id in extras = .load(for: id) }
        .onChange(of: extras) { $0.save(for: editor.document.id) }
        .trackScreen(.fieldInfo)
    }

    // MARK: - Bindings

    private func isExpanded(_ row: DateRow) -> Binding<Bool> {
        Binding(
            get: { expandedDate == row },
            set: { expandedDate = $0 ? row : nil }
        )
    }

    /// Changing the issue date keeps fixed terms ("7 Days", "Due on receipt"…) in step.
    private var issueDate: Binding<Date> {
        Binding(
            get: { editor.document.issueDate },
            set: { newValue in
                var document = editor.document
                document.issueDate = newValue
                if extras.termsNone {
                    document.dueDate = newValue
                } else if let days = document.terms.fieldFixedDays {
                    document.dueDate = Self.date(newValue, plusDays: days)
                }
                editor.document = document
            }
        )
    }

    /// Picking a due date by hand makes the terms custom.
    private var dueDate: Binding<Date> {
        Binding(
            get: { editor.document.dueDate },
            set: { newValue in
                var document = editor.document
                document.dueDate = newValue
                document.terms = .custom
                editor.document = document
                extras.termsNone = false
            }
        )
    }

    // MARK: - Terms

    private func applyTerms(_ option: FieldTermsOption) {
        var document = editor.document
        extras.termsNone = option == .none
        switch option {
        case .none, .dueOnReceipt:
            document.terms = .dueOnReceipt
            document.dueDate = document.issueDate
        case .customDate:
            document.terms = .custom
            expandedDate = .due
        case .days(let count):
            document.terms = count == 7 ? .net7 : .custom
            document.dueDate = Self.date(document.issueDate, plusDays: count)
        }
        editor.document = document
    }

    private static func date(_ date: Date, plusDays days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }
}

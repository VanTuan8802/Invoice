//
//  FieldRecurringViewModel.swift
//  Invoice
//
//  Draft of the recurring schedule edited on Invoice/Recurring. `repeatInterval`
//  is written to the document on Save; start/end dates and delivery settings have
//  no model field yet and are kept in `FieldDocumentExtras`.
//

import Foundation

@MainActor
final class FieldRecurringViewModel: ObservableObject {
    @Published var interval: RepeatInterval = .monthly
    @Published var startDate = Date()
    /// `nil` = never ends.
    @Published var endDate: Date?
    @Published var sendsAutomatically = true
    @Published var email = ""

    private var loadedDocumentID: UUID?

    var footer: String {
        interval.fieldFooter(sendsAutomatically: sendsAutomatically)
    }

    /// Fills the draft from the document (once per document).
    func load(from document: Document) {
        guard loadedDocumentID != document.id else { return }
        loadedDocumentID = document.id
        let extras = FieldDocumentExtras.load(for: document.id)
        // Opening the screen means setting up a schedule: start from "Monthly".
        interval = document.repeatInterval == .never ? .monthly : document.repeatInterval
        startDate = extras.recurringStart ?? document.issueDate
        endDate = extras.recurringEnd
        sendsAutomatically = extras.recurringSendsAutomatically
        email = extras.recurringEmail ?? document.client?.email ?? ""
    }

    /// "Ends > On a Date": default to one year after the start.
    func endOnDate() {
        if endDate == nil {
            endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }

    func save(into editor: DocumentEditor) {
        editor.document.repeatInterval = interval
        var extras = FieldDocumentExtras.load(for: editor.document.id)
        extras.recurringStart = startDate
        extras.recurringEnd = endDate
        extras.recurringSendsAutomatically = sendsAutomatically
        extras.recurringEmail = email
        extras.save(for: editor.document.id)
    }
}

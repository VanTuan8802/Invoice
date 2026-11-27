//
//  DocumentHistoryLog.swift
//  Invoice
//
//  In-memory activity log per document for the History tab ("Sent", "Reminder
//  sent"…). `Document` has no history field, so the log lives here; "Marked as
//  paid" is derived from `Document.paidDate`.
//

import SwiftUI
import Factory

enum DocumentHistoryEvent: String, Hashable {
    case sent
    case reminder
    case shared
    case paid

    var title: String {
        switch self {
        case .sent:     return R.stringLocalizable.doc_history_sent()
        case .reminder: return R.stringLocalizable.doc_history_reminder()
        case .shared:   return R.stringLocalizable.doc_history_shared()
        case .paid:     return R.stringLocalizable.doc_history_paid()
        }
    }
}

struct DocumentHistoryEntry: Identifiable, Hashable {
    var id = UUID()
    var event: DocumentHistoryEvent
    var date: Date
}

@MainActor
final class DocumentHistoryLog: ObservableObject {
    @Published private var log: [UUID: [DocumentHistoryEntry]] = [:]

    func record(_ event: DocumentHistoryEvent, for documentID: UUID, at date: Date = Date()) {
        log[documentID, default: []].append(DocumentHistoryEntry(event: event, date: date))
    }

    /// Logged events plus the paid event, newest first.
    func entries(for document: Document) -> [DocumentHistoryEntry] {
        var entries = log[document.id] ?? []
        if document.status == .paid, let paidDate = document.paidDate {
            entries.append(DocumentHistoryEntry(event: .paid, date: paidDate))
        }
        return entries.sorted { $0.date > $1.date }
    }
}

extension Container {
    /// History tab activity log (Edit / Preview / History editor).
    var documentHistory: Factory<DocumentHistoryLog> {
        Factory(self) { @MainActor in
            let log = DocumentHistoryLog()
            #if DEBUG
            // `-uiPreview` sessions: give the sample documents a "Sent" record so the
            // History tab has content to check against the design.
            if UIPreview.destination != nil, !UIPreview.isEmptyData {
                let store = self.dataStore()
                for document in [store.invoices.first, store.estimates.first].compactMap({ $0 }) {
                    log.record(.sent, for: document.id, at: Date().addingTimeInterval(-3_600))
                }
            }
            #endif
            return log
        }.singleton
    }
}

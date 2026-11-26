//
//  DocumentFilter.swift
//  Invoice
//
//  Filter / sort options set on Invoice/Filter and applied by Invoice/Search.
//  Kept per document kind in a shared, in-memory store (not part of `Domain/`).
//

import Foundation
import Factory

enum DocumentSort: String, Hashable, CaseIterable, Identifiable {
    case newestFirst
    case amountHighToLow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newestFirst:     return R.stringLocalizable.doc_sort_newest()
        case .amountHighToLow: return R.stringLocalizable.doc_sort_amount()
        }
    }
}

struct DocumentFilter: Equatable {
    /// Empty = every status.
    var statuses: Set<DocumentDisplayStatus> = []
    var fromDate: Date?
    var toDate: Date?
    /// `nil` = all clients.
    var clientID: UUID?
    var sort: DocumentSort = .newestFirst

    var isActive: Bool {
        !statuses.isEmpty || fromDate != nil || toDate != nil || clientID != nil
    }

    func apply(to documents: [Document]) -> [Document] {
        let calendar = Calendar.current
        let filtered = documents.filter { document in
            if !statuses.isEmpty, !statuses.contains(document.displayStatus) { return false }
            if let fromDate, document.issueDate < calendar.startOfDay(for: fromDate) { return false }
            if let toDate,
               let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: toDate)),
               document.issueDate >= end { return false }
            if let clientID, document.client?.id != clientID { return false }
            return true
        }
        switch sort {
        case .newestFirst:     return filtered.sorted { $0.issueDate > $1.issueDate }
        case .amountHighToLow: return filtered.sorted { $0.total > $1.total }
        }
    }
}

@MainActor
final class DocumentFilterStore: ObservableObject {
    @Published private var filters: [DocumentKind: DocumentFilter] = [:]

    subscript(kind: DocumentKind) -> DocumentFilter {
        get { filters[kind] ?? DocumentFilter() }
        set { filters[kind] = newValue }
    }
}

extension Container {
    /// Search filters per document kind (Invoice/Filter ↔ Invoice/Search).
    var documentFilters: Factory<DocumentFilterStore> {
        Factory(self) { @MainActor in DocumentFilterStore() }.singleton
    }
}

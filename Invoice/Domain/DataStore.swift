//
//  DataStore.swift
//  Invoice
//
//  In-memory app data (seeded with sample content). Injected via Factory:
//  `@InjectedObject(\.dataStore) private var store: DataStore`.
//

import Foundation
import Combine

@MainActor
final class DataStore: ObservableObject {
    static let defaultCurrencyCode = "USD"

    @Published var invoices: [Document]
    @Published var estimates: [Document]
    @Published var clients: [Client]
    @Published var items: [CatalogItem]
    @Published var business: BusinessProfile
    @Published var currencyCode: String = DataStore.defaultCurrencyCode

    /// - Parameter seeded: `false` starts empty (used by `-uiPreviewEmpty` to show empty states).
    init(seeded: Bool = true) {
        invoices = seeded ? SampleData.invoices : []
        estimates = seeded ? SampleData.estimates : []
        clients = seeded ? SampleData.clients : []
        items = seeded ? SampleData.items : []
        business = seeded ? SampleData.business : BusinessProfile()
    }

    // MARK: Documents

    func documents(_ kind: DocumentKind) -> [Document] {
        kind == .invoice ? invoices : estimates
    }

    func document(id: UUID) -> Document? {
        (invoices + estimates).first { $0.id == id }
    }

    func upsert(_ document: Document) {
        switch document.kind {
        case .invoice:  upsert(document, into: &invoices)
        case .estimate: upsert(document, into: &estimates)
        }
    }

    func delete(_ document: Document) {
        invoices.removeAll { $0.id == document.id }
        estimates.removeAll { $0.id == document.id }
    }

    /// Next number for a new document, e.g. "INV0003" / "EST0002".
    func nextNumber(for kind: DocumentKind) -> String {
        let prefix = kind == .invoice ? "INV" : "EST"
        return prefix + String(format: "%04d", documents(kind).count + 1)
    }

    // MARK: Clients & items

    func upsert(_ client: Client) {
        if let index = clients.firstIndex(where: { $0.id == client.id }) {
            clients[index] = client
        } else {
            clients.append(client)
        }
    }

    func upsert(_ item: CatalogItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    private func upsert(_ document: Document, into list: inout [Document]) {
        if let index = list.firstIndex(where: { $0.id == document.id }) {
            list[index] = document
        } else {
            list.insert(document, at: 0)
        }
    }
}

/// The invoice/estimate currently open in the editor. Edit/Preview/History and
/// every field screen (discount, tax, payment, note…) read and write `document`;
/// `save()` writes it back to the store.
@MainActor
final class DocumentEditor: ObservableObject {
    @Published var document: Document
    private let store: DataStore

    init(store: DataStore) {
        self.store = store
        self.document = Document(kind: .invoice, number: "")
    }

    /// Start editing an existing document, or a fresh one when `id` is nil.
    func begin(kind: DocumentKind, id: UUID?) {
        if let id, let existing = store.document(id: id) {
            document = existing
        } else {
            document = Document(kind: kind, number: store.nextNumber(for: kind))
        }
    }

    func save() {
        store.upsert(document)
    }
}

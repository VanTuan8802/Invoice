//
//  ItemEditViewModel.swift
//  Invoice
//
//  Draft state for Item/Edit — a "My Items" catalog entry. Saving validates the
//  fields; when something is missing or not a number the screen shows the
//  Invalid Fields alert instead.
//

import Foundation
import Factory

@MainActor
final class ItemEditViewModel: ObservableObject {
    @Published var name: String
    @Published var price: String
    @Published var quantity: String
    @Published var discount: String
    @Published var isTaxable: Bool
    @Published var note: String

    @Published var isShowingInvalidAlert = false

    private let original: CatalogItem
    private let store: DataStore

    /// - Parameter itemID: the catalog item to edit, or `nil` to create one.
    init(itemID: UUID?) {
        let store = Container.shared.dataStore()
        self.store = store
        let item = itemID.flatMap { id in store.items.first { $0.id == id } }
            ?? CatalogItem(id: itemID ?? UUID(), name: "")
        original = item

        name = item.name
        price = ClientItemNumberInput.text(for: item.price, hiding: 0)
        quantity = ClientItemNumberInput.text(for: item.quantity, hiding: 1)
        discount = ClientItemNumberInput.text(for: item.discountPercent, hiding: 0)
        isTaxable = item.isTaxable
        note = item.note
    }

    var pricePlaceholder: String { Decimal(0).currencyText(code: store.currencyCode) }

    /// Writes the item to the store. Returns `false` (and raises the Invalid
    /// Fields alert) when a field is missing or invalid.
    func save() -> Bool {
        guard let item = validatedItem else {
            isShowingInvalidAlert = true
            return false
        }
        store.upsert(item)
        return true
    }

    private var validatedItem: CatalogItem? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let price = ClientItemNumberInput.decimal(from: price, fallback: 0), price >= 0,
              let quantity = ClientItemNumberInput.decimal(from: quantity, fallback: 1), quantity > 0,
              let discount = ClientItemNumberInput.decimal(from: discount, fallback: 0), (0...100).contains(discount)
        else { return nil }

        var item = original
        item.name = trimmedName
        item.price = price
        item.quantity = quantity
        item.discountPercent = discount
        item.isTaxable = isTaxable
        item.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return item
    }
}

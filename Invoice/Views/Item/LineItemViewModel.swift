//
//  LineItemViewModel.swift
//  Invoice
//
//  Draft state for Item/Info — a line item on the document open in
//  `DocumentEditor`. "Done" writes it back to the document and, when
//  "Save to “My Items”" is on, also upserts it into the catalog.
//

import Foundation
import Factory

enum LineItemDiscountMode: CaseIterable, Hashable {
    /// "Not Discount"
    case none
    case percentage
    case fixedAmount

    var title: String {
        switch self {
        case .none:        return R.stringLocalizable.item_no_discount()
        case .percentage:  return R.stringLocalizable.item_discount_percentage()
        case .fixedAmount: return R.stringLocalizable.item_discount_fixed()
        }
    }
}

@MainActor
final class LineItemViewModel: ObservableObject {
    @Published var name: String
    @Published var price: String
    @Published var quantity: String
    @Published var discountMode: LineItemDiscountMode
    @Published var discountValue: String
    @Published var isTaxable: Bool
    /// Per-item tax rate. `LineItem` has no field for it yet, so it only lives
    /// on this screen (validated, not persisted).
    @Published var taxRate: String = ""
    @Published var note: String
    @Published var saveToMyItems: Bool

    @Published var isShowingInvalidAlert = false

    /// `true` when the item is not in "My Items" yet (always for a new item):
    /// shows the "Save to “My Items”" switch (Item/Info/Save To My Items).
    let showsSaveToMyItems: Bool

    private let original: LineItem
    private let editor: DocumentEditor
    private let store: DataStore

    /// - Parameter lineItemID: the line item on the open document, or `nil` to add one.
    init(lineItemID: UUID?) {
        let editor = Container.shared.documentEditor()
        let store = Container.shared.dataStore()
        self.editor = editor
        self.store = store

        let existing = lineItemID.flatMap { id in editor.document.items.first { $0.id == id } }
        let item = existing ?? LineItem(name: "")
        original = item

        name = item.name
        price = ClientItemNumberInput.text(for: item.price, hiding: 0)
        quantity = ClientItemNumberInput.text(for: item.quantity, hiding: 1)
        discountMode = item.discountPercent > 0 ? .percentage : .none
        discountValue = ClientItemNumberInput.text(for: item.discountPercent, hiding: 0)
        isTaxable = item.isTaxable
        note = item.detail

        let isInCatalog = store.items.contains { $0.name.caseInsensitiveCompare(item.name) == .orderedSame }
        showsSaveToMyItems = existing == nil || !isInCatalog
        saveToMyItems = existing == nil
    }

    // MARK: Placeholders

    var pricePlaceholder: String { Decimal(0).currencyText(code: store.currencyCode) }

    var discountPlaceholder: String {
        switch discountMode {
        case .none:        return Decimal(0).plainText
        case .percentage:  return Decimal(0).percentText
        case .fixedAmount: return Decimal(0).currencyText(code: store.currencyCode)
        }
    }

    // MARK: Actions

    /// Writes the line item to the open document. Returns `false` (and raises
    /// the Invalid Fields alert) when a field is missing or invalid.
    func done() -> Bool {
        guard let item = validatedItem else {
            isShowingInvalidAlert = true
            return false
        }

        if let index = editor.document.items.firstIndex(where: { $0.id == item.id }) {
            editor.document.items[index] = item
        } else {
            editor.document.items.append(item)
        }

        if showsSaveToMyItems && saveToMyItems {
            saveToCatalog(item)
        }
        return true
    }

    private var validatedItem: LineItem? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let price = ClientItemNumberInput.decimal(from: price, fallback: 0), price >= 0,
              let quantity = ClientItemNumberInput.decimal(from: quantity, fallback: 1), quantity > 0,
              let tax = ClientItemNumberInput.decimal(from: taxRate, fallback: 0), (0...100).contains(tax),
              let discountPercent = discountPercent(gross: price * quantity)
        else { return nil }

        var item = original
        item.name = trimmedName
        item.price = price
        item.quantity = quantity
        item.discountPercent = discountPercent
        item.isTaxable = isTaxable
        item.detail = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return item
    }

    /// The discount as a percentage of `gross` (a fixed amount is converted),
    /// or `nil` when the entered value is invalid.
    private func discountPercent(gross: Decimal) -> Decimal? {
        switch discountMode {
        case .none:
            return 0
        case .percentage:
            guard let value = ClientItemNumberInput.decimal(from: discountValue, fallback: 0),
                  (0...100).contains(value) else { return nil }
            return value
        case .fixedAmount:
            guard let value = ClientItemNumberInput.decimal(from: discountValue, fallback: 0),
                  value >= 0, value <= gross else { return nil }
            return gross > 0 ? value / gross * 100 : 0
        }
    }

    private func saveToCatalog(_ item: LineItem) {
        let existingID = store.items.first { $0.name.caseInsensitiveCompare(item.name) == .orderedSame }?.id
        store.upsert(CatalogItem(id: existingID ?? UUID(),
                                 name: item.name,
                                 price: item.price,
                                 quantity: item.quantity,
                                 discountPercent: item.discountPercent,
                                 isTaxable: item.isTaxable,
                                 note: item.detail))
    }
}

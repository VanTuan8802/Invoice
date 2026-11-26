//
//  ItemRoute.swift
//  Invoice
//
//  Item screens (`Destination.item`). Owned by the Item feature.
//

import SwiftUI

enum ItemRoute: Hashable {
    /// Item/List (+ Empty). `isPicker == true` when adding an item to a document.
    case list(isPicker: Bool)
    /// Item/Info (+ Save To My Items) — a line item on the open document.
    case lineItem(id: UUID?)
    /// Item/Edit (+ Invalid Fields Dialog) — a "My Items" catalog entry. `nil` = new.
    case edit(id: UUID?)

    var identifier: String {
        switch self {
        case .list(let isPicker): return "item.list.\(isPicker)"
        case .lineItem(let id):   return "item.lineItem.\(id?.uuidString ?? "new")"
        case .edit(let id):       return "item.edit.\(id?.uuidString ?? "new")"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .list, .lineItem, .edit:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: ItemRoute] {
        ["item.list": .list(isPicker: false)]
    }
    #endif
}

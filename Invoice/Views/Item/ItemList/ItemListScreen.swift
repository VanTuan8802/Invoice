//
//  ItemListScreen.swift
//  Invoice
//
//  Item/List (+ Empty): the "My Items" catalog. Picker mode (opened from the
//  invoice editor) adds the tapped item to the open document as a line item and
//  goes back; otherwise a row opens Item/Edit.
//

import SwiftUI
import Factory

struct ItemListScreen: View {
    let isPicker: Bool

    @InjectedObject(\.dataStore) private var store: DataStore
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @Injected(\.app) private var app

    @State private var sort: ItemListSort = .name
    @State private var isShowingSortOptions = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.item_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderIconButton(systemImage: "ellipsis") { isShowingSortOptions = true }
            })

            if store.items.isEmpty {
                ClientItemEmptyState(
                    image: R.image.illus_item,
                    tileColor: Color(R.color.colorFFEBD9),
                    title: R.stringLocalizable.item_empty_title(),
                    message: R.stringLocalizable.item_empty_message()
                )
            } else {
                list
            }
        }
        .groupedScreenBackground()
        .floatingActionButton {
            app.navi.push(.item(.edit(id: nil)))
        }
        .confirmationDialog(R.stringLocalizable.item_sort_title(),
                            isPresented: $isShowingSortOptions,
                            titleVisibility: .visible) {
            Button(R.stringLocalizable.item_sort_name()) { sort = .name }
            Button(R.stringLocalizable.item_sort_price()) { sort = .price }
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
        }
        .trackScreen(isPicker ? .itemPicker : .itemList)
    }

    private var list: some View {
        List {
            Section {
                ForEach(sortedItems) { item in
                    Button {
                        select(item)
                    } label: {
                        ItemListRowView(item: item, currencyCode: store.currencyCode)
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .clientItemSectionSpacing()
        // Keep the last rows clear of the floating "+" button.
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 68) }
    }

    private var sortedItems: [CatalogItem] {
        switch sort {
        case .name:
            return store.items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .price:
            return store.items.sorted { $0.price > $1.price }
        }
    }

    private func select(_ item: CatalogItem) {
        if isPicker {
            editor.document.items.append(
                LineItem(name: item.name,
                         detail: item.note,
                         price: item.price,
                         quantity: item.quantity,
                         discountPercent: item.discountPercent,
                         isTaxable: item.isTaxable)
            )
            app.navi.pop()
        } else {
            app.navi.push(.item(.edit(id: item.id)))
        }
    }
}

enum ItemListSort {
    case name
    case price
}

private struct ItemListRowView: View {
    let item: CatalogItem
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            Text(item.name)
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(item.price.currencyText(code: currencyCode))
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
        }
        .contentShape(Rectangle())
    }
}

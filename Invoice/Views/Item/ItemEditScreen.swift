//
//  ItemEditScreen.swift
//  Invoice
//
//  Item/Edit (+ Invalid Fields Dialog): name, price, quantity, discount %,
//  taxable and notes for a "My Items" catalog entry.
//

import SwiftUI
import Factory

struct ItemEditScreen: View {
    @StateObject private var viewModel: ItemEditViewModel
    @Injected(\.app) private var app

    init(itemID: UUID?) {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(itemID: itemID))
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.item_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderTextButton(title: R.stringLocalizable.save()) {
                    if viewModel.save() { app.navi.pop() }
                }
            })

            Form {
                Section {
                    ClientItemPlainInputRow(
                        placeholder: R.stringLocalizable.item_name_placeholder(),
                        text: $viewModel.name,
                        font: .body
                    )
                    ClientItemInputRow(
                        label: R.stringLocalizable.item_price(),
                        placeholder: viewModel.pricePlaceholder,
                        text: $viewModel.price,
                        keyboard: .decimalPad
                    )
                    ClientItemInputRow(
                        label: R.stringLocalizable.item_quantity(),
                        placeholder: Decimal(1).plainText,
                        text: $viewModel.quantity,
                        keyboard: .decimalPad
                    )
                    ClientItemInputRow(
                        label: R.stringLocalizable.item_discount_amount(),
                        placeholder: Decimal(0).percentText,
                        text: $viewModel.discount,
                        keyboard: .decimalPad
                    )
                    ClientItemToggleRow(label: R.stringLocalizable.item_taxable(), isOn: $viewModel.isTaxable)
                }

                Section {
                    ClientItemNotesRow(placeholder: R.stringLocalizable.item_others(), text: $viewModel.note)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .clientItemSectionSpacing()
        }
        .groupedScreenBackground()
        .alert(R.stringLocalizable.item_invalid_title(), isPresented: $viewModel.isShowingInvalidAlert) {
            Button(R.stringLocalizable.common_discard(), role: .destructive) {
                app.navi.pop()
            }
            // Cancel role keeps the alert to two side-by-side buttons; it is
            // also the preferred (prominent) action.
            Button(R.stringLocalizable.common_edit(), role: .cancel) {}
                .keyboardShortcut(.defaultAction)
        }
        .trackScreen(.itemEdit)
    }
}

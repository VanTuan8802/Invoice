//
//  LineItemScreen.swift
//  Invoice
//
//  Item/Info (+ Save To My Items): edits a line item on the open document
//  (`nil` adds a new one). "Done" writes it back; the extra card offers to keep
//  the item in "My Items" too.
//

import SwiftUI
import Factory

struct LineItemScreen: View {
    @StateObject private var viewModel: LineItemViewModel
    @Injected(\.app) private var app

    init(lineItemID: UUID?) {
        _viewModel = StateObject(wrappedValue: LineItemViewModel(lineItemID: lineItemID))
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.item_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderTextButton(title: R.stringLocalizable.common_done()) {
                    if viewModel.done() { app.navi.pop() }
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
                    discountPicker
                    ClientItemInputRow(
                        label: R.stringLocalizable.item_discount_amount(),
                        placeholder: viewModel.discountPlaceholder,
                        text: $viewModel.discountValue,
                        keyboard: .decimalPad
                    )
                    .disabled(viewModel.discountMode == .none)
                    ClientItemToggleRow(label: R.stringLocalizable.item_taxable(), isOn: $viewModel.isTaxable)
                    ClientItemInputRow(
                        label: R.stringLocalizable.item_tax_rate(),
                        placeholder: Decimal(0).percentText,
                        text: $viewModel.taxRate,
                        keyboard: .decimalPad
                    )
                }

                Section {
                    ClientItemNotesRow(placeholder: R.stringLocalizable.item_others(), text: $viewModel.note)
                }

                if viewModel.showsSaveToMyItems {
                    Section {
                        ClientItemToggleRow(label: R.stringLocalizable.item_save_to_my_items(),
                                            isOn: $viewModel.saveToMyItems)
                    }
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
            Button(R.stringLocalizable.common_edit(), role: .cancel) {}
                .keyboardShortcut(.defaultAction)
        }
        .trackScreen(.itemLineItem)
    }

    /// "Discount:  Not Discount" — menu picker in ink.
    private var discountPicker: some View {
        Picker(selection: $viewModel.discountMode) {
            ForEach(LineItemDiscountMode.allCases, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        } label: {
            Text(R.stringLocalizable.item_discount())
                .font(.body)
                .foregroundStyle(Color(R.color.color111118))
        }
        .pickerStyle(.menu)
        .tint(Color(R.color.color111118))
    }
}

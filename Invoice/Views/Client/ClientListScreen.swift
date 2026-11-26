//
//  ClientListScreen.swift
//  Invoice
//
//  Client/List (+ Empty). Each row shows the client's invoice count and total;
//  invoices without a client are grouped under "No Client".
//  Picker mode (opened from the invoice editor) sets the document's client and
//  goes back; otherwise a row opens Client/Info.
//

import SwiftUI
import Factory

struct ClientListScreen: View {
    let isPicker: Bool

    @InjectedObject(\.dataStore) private var store: DataStore
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @Injected(\.app) private var app

    @State private var sort: ClientListSort = .name
    @State private var isShowingSortOptions = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.client_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderIconButton(systemImage: "ellipsis") { isShowingSortOptions = true }
            })

            if rows.isEmpty {
                ClientItemEmptyState(
                    image: R.image.illus_client,
                    tileColor: Color(R.color.colorFFE6F3),
                    title: R.stringLocalizable.client_empty_title(),
                    message: R.stringLocalizable.client_empty_message()
                )
            } else {
                list
            }
        }
        .groupedScreenBackground()
        .floatingActionButton {
            app.navi.push(.client(.edit(id: nil)))
        }
        .confirmationDialog(R.stringLocalizable.client_sort_title(),
                            isPresented: $isShowingSortOptions,
                            titleVisibility: .visible) {
            Button(R.stringLocalizable.client_sort_name()) { sort = .name }
            Button(R.stringLocalizable.client_sort_amount()) { sort = .amount }
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
        }
        .trackScreen(isPicker ? .clientPicker : .clientList)
    }

    private var list: some View {
        List {
            Section {
                ForEach(rows) { row in
                    Button {
                        select(row)
                    } label: {
                        ClientListRowView(row: row, currencyCode: store.currencyCode)
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

    // MARK: Data

    private var rows: [ClientListRow] {
        let invoices = store.invoices
        var clientRows = store.clients.map { client in
            let mine = invoices.filter { $0.client?.id == client.id }
            return ClientListRow(client: client, invoiceCount: mine.count, total: mine.clientListTotal)
        }
        switch sort {
        case .name:
            clientRows.sort { $0.client?.name.localizedCaseInsensitiveCompare($1.client?.name ?? "") == .orderedAscending }
        case .amount:
            clientRows.sort { $0.total > $1.total }
        }

        let unassigned = invoices.filter { $0.client == nil }
        guard !unassigned.isEmpty else { return clientRows }
        return [ClientListRow(client: nil, invoiceCount: unassigned.count, total: unassigned.clientListTotal)] + clientRows
    }

    private func select(_ row: ClientListRow) {
        if isPicker {
            editor.document.client = row.client
            app.navi.pop()
        } else if let client = row.client {
            app.navi.push(.client(.detail(id: client.id)))
        }
    }
}

// MARK: - Row

enum ClientListSort {
    case name
    case amount
}

struct ClientListRow: Identifiable {
    /// `nil` = invoices without a client ("No Client").
    let client: Client?
    let invoiceCount: Int
    let total: Decimal

    var id: UUID? { client?.id }
}

private struct ClientListRowView: View {
    let row: ClientListRow
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(row.client?.name ?? R.stringLocalizable.client_no_client())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color111118))
                    .lineLimit(1)
                Text(ClientItemText.invoiceCount(row.invoiceCount))
                    .font(.footnote)
                    .foregroundStyle(Color(R.color.color6B6B78))
            }
            Spacer(minLength: 8)
            Text(row.total.currencyText(code: currencyCode))
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color111118))
        }
        .contentShape(Rectangle())
    }
}

private extension Array where Element == Document {
    var clientListTotal: Decimal { reduce(0) { $0 + $1.total } }
}

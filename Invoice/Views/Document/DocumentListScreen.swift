//
//  DocumentListScreen.swift
//  Invoice
//
//  Invoice/List (+ Empty) and Estimate/List (+ Empty).
//

import SwiftUI
import Factory

struct DocumentListScreen: View {
    let kind: DocumentKind

    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @State private var pendingDelete: Document?

    private var documents: [Document] { store.documents(kind) }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(kind.title, showBack: true, backAction: { app.navi.pop() }, trailingView: {
                Menu {
                    Button {
                        app.navi.push(.document(.search(kind)))
                    } label: {
                        Label(R.stringLocalizable.doc_search_title(), systemImage: "magnifyingglass")
                    }
                    Button {
                        app.navi.push(.document(.filter(kind)))
                    } label: {
                        Label(R.stringLocalizable.doc_filter(), systemImage: "line.3.horizontal.decrease")
                    }
                } label: {
                    HeaderMenuLabel()
                }
            })

            if kind == .invoice {
                SearchEntryField(placeholder: R.stringLocalizable.doc_search_invoices()) {
                    app.navi.push(.document(.search(kind)))
                }
                .padding(.horizontal, 16)
                .padding(.top, 19)
            }

            if documents.isEmpty {
                DocumentEmptyStateView(
                    image: kind.emptyIllustration,
                    tile: kind.emptyTileColor,
                    title: kind.emptyTitle,
                    message: kind.emptyMessage
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(documents) { document in
                            row(document)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, kind == .invoice ? 16 : 8)
                    .padding(.bottom, 96)
                }
            }
        }
        .groupedScreenBackground()
        .floatingActionButton {
            app.navi.push(.document(.editor(kind, id: nil)))
        }
        .alert(
            R.stringLocalizable.doc_delete_title(),
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            presenting: pendingDelete
        ) { document in
            Button(R.stringLocalizable.common_delete(), role: .destructive) { store.delete(document) }
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
        } message: { _ in
            Text(R.stringLocalizable.doc_delete_message())
        }
        .trackScreen(kind.listScreen)
    }

    private func row(_ document: Document) -> some View {
        Button {
            app.navi.push(.document(.editor(kind, id: document.id)))
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.clientDisplayName)
                        .font(.subheadline)
                        .foregroundStyle(Color(R.color.color111118))
                    Text(document.number)
                        .font(.footnote)
                        .foregroundStyle(Color(R.color.color6B6B78))
                }
                .lineLimit(1)
                Spacer(minLength: 8)
                Text(document.total.currencyText(code: store.currencyCode))
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color111118))
            }
            .cardSurface()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                pendingDelete = document
            } label: {
                Label(R.stringLocalizable.common_delete(), systemImage: "trash")
            }
        }
    }
}

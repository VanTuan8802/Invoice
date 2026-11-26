//
//  DocumentSearchScreen.swift
//  Invoice
//
//  Invoice/Search (recent searches) and Invoice/Search/Results. "Filter" opens
//  Invoice/Filter; its options are applied on top of the query and status chip.
//

import SwiftUI
import Factory

struct DocumentSearchScreen: View {
    let kind: DocumentKind

    @InjectedObject(\.dataStore) private var store: DataStore
    @InjectedObject(\.documentFilters) private var filters: DocumentFilterStore
    @Injected(\.app) private var app

    @State private var query = ""
    @State private var chip: DocumentDisplayStatus?
    @AppStorage private var recentStorage: String

    init(kind: DocumentKind) {
        self.kind = kind
        _recentStorage = AppStorage(wrappedValue: "", "document.recentSearches.\(kind.rawValue)")
    }

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var recentSearches: [String] {
        recentStorage.split(separator: "\n").map(String.init)
    }

    private var showsResults: Bool {
        !trimmedQuery.isEmpty || chip != nil || filters[kind].isActive
    }

    private var results: [Document] {
        var documents = filters[kind].apply(to: store.documents(kind))
        if let chip {
            documents = documents.filter { $0.displayStatus == chip }
        }
        if !trimmedQuery.isEmpty {
            documents = documents.filter {
                $0.number.localizedCaseInsensitiveContains(trimmedQuery)
                    || ($0.client?.name.localizedCaseInsensitiveContains(trimmedQuery) ?? false)
            }
        }
        return documents
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.doc_search_title(), showBack: true, backAction: { app.navi.pop() }, trailingView: {
                HeaderGlassTextButton(title: R.stringLocalizable.doc_filter()) {
                    app.navi.push(.document(.filter(kind)))
                }
            })

            SearchEntryField(placeholder: kind.searchPlaceholder, text: $query)
                .overlay(alignment: .trailing) {
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(R.image.ic_document_search_clear)
                                .frame(width: 32, height: 44)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 6)
                    }
                }
                .onSubmit(rememberQuery)
                .padding(.horizontal, 16)
                .padding(.top, 13)

            chips
                .padding(.horizontal, 16)
                .padding(.top, 16)

            list
        }
        .groupedScreenBackground()
        .onAppear(perform: applyDebugQuery)
        .trackScreen(.documentSearch)
    }

    /// DEBUG: `-uiPreviewSearch <text>` pre-fills the query (Invoice/Search/Results check).
    private func applyDebugQuery() {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-uiPreviewSearch"), index + 1 < arguments.count, query.isEmpty {
            query = arguments[index + 1]
        }
        #endif
    }

    // MARK: - Sections

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                DocumentFilterChip(title: R.stringLocalizable.doc_status_all(), isSelected: chip == nil) {
                    chip = nil
                }
                ForEach(DocumentDisplayStatus.allCases) { status in
                    DocumentFilterChip(title: status.title, isSelected: chip == status) {
                        chip = status
                    }
                }
            }
        }
    }

    private var list: some View {
        List {
            if showsResults {
                Section {
                    ForEach(results) { document in
                        resultRow(document)
                    }
                } header: {
                    sectionHeader(resultsTitle)
                }
            } else if !recentSearches.isEmpty {
                Section {
                    ForEach(recentSearches, id: \.self) { recent in
                        Button {
                            query = recent
                        } label: {
                            Text(recent)
                                .font(.body)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    sectionHeader(R.stringLocalizable.doc_recent_searches())
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var resultsTitle: String {
        switch results.count {
        case 0:  return R.stringLocalizable.doc_no_results()
        case 1:  return R.stringLocalizable.doc_results_one()
        default: return R.stringLocalizable.doc_results_count(results.count)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.secondary)
            .textCase(nil)
            .padding(.leading, -8)
    }

    private func resultRow(_ document: Document) -> some View {
        Button {
            rememberQuery()
            app.navi.push(.document(.editor(kind, id: document.id)))
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.clientDisplayName)
                        .font(.body)
                        .foregroundStyle(Color.primary)
                    Text(document.resultSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .lineLimit(1)
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(document.total.currencyText(code: store.currencyCode))
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    DocumentStatusChip(status: document.displayStatus)
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent searches

    private func rememberQuery() {
        let text = trimmedQuery
        guard !text.isEmpty else { return }
        var recents = recentSearches.filter { $0.caseInsensitiveCompare(text) != .orderedSame }
        recents.insert(text, at: 0)
        recentStorage = recents.prefix(5).joined(separator: "\n")
    }
}

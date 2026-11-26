//
//  DocumentFilterScreen.swift
//  Invoice
//
//  Invoice/Filter: status, date range, client and sort for the search results.
//  Edits a draft; "Apply" / "Show N Invoices" commit it and go back.
//

import SwiftUI
import Factory

struct DocumentFilterScreen: View {
    let kind: DocumentKind

    @InjectedObject(\.dataStore) private var store: DataStore
    @InjectedObject(\.documentFilters) private var filters: DocumentFilterStore
    @Injected(\.app) private var app

    @State private var draft = DocumentFilter()
    @State private var didLoad = false
    @State private var editingDate: DateField?

    private enum DateField { case from, to }

    private var matchCount: Int { draft.apply(to: store.documents(kind)).count }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(
                R.stringLocalizable.doc_filters_title(),
                leadingView: {
                    HeaderGlassTextButton(title: R.stringLocalizable.doc_filter_reset()) {
                        draft = DocumentFilter()
                        editingDate = nil
                    }
                },
                trailingView: {
                    HeaderTextButton(title: R.stringLocalizable.doc_filter_apply(), action: apply)
                }
            )

            List {
                statusSection
                dateSection
                clientSection
                sortSection
                Section {
                    ProminentWideButton(title: kind.showCountTitle(matchCount), action: apply)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .groupedScreenBackground()
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            draft = filters[kind]
        }
        .trackScreen(.documentFilter)
    }

    // MARK: - Sections

    private var statusSection: some View {
        Section {
            ForEach(DocumentDisplayStatus.allCases) { status in
                checkRow(status.title, isChecked: draft.statuses.contains(status)) {
                    if draft.statuses.contains(status) {
                        draft.statuses.remove(status)
                    } else {
                        draft.statuses.insert(status)
                    }
                }
            }
        } header: {
            sectionHeader(R.stringLocalizable.doc_filter_status())
        }
    }

    private var dateSection: some View {
        Section {
            dateRow(R.stringLocalizable.doc_filter_from(), date: draft.fromDate, field: .from)
            if editingDate == .from {
                datePicker(Binding(get: { draft.fromDate ?? Date() }, set: { draft.fromDate = $0 }))
            }
            dateRow(R.stringLocalizable.doc_filter_to(), date: draft.toDate, field: .to)
            if editingDate == .to {
                datePicker(Binding(get: { draft.toDate ?? Date() }, set: { draft.toDate = $0 }))
            }
        } header: {
            sectionHeader(R.stringLocalizable.doc_filter_date_range())
        }
    }

    private var clientSection: some View {
        Section {
            Menu {
                Button(R.stringLocalizable.doc_filter_all_clients()) { draft.clientID = nil }
                ForEach(store.clients) { client in
                    Button(client.name) { draft.clientID = client.id }
                }
            } label: {
                valueRow(R.stringLocalizable.doc_client(), value: clientName)
            }
        } header: {
            sectionHeader(R.stringLocalizable.doc_client())
        }
    }

    private var sortSection: some View {
        Section {
            ForEach(DocumentSort.allCases) { sort in
                checkRow(sort.title, isChecked: draft.sort == sort) { draft.sort = sort }
            }
        } header: {
            sectionHeader(R.stringLocalizable.doc_filter_sort_by())
        }
    }

    // MARK: - Rows

    private var clientName: String {
        guard let id = draft.clientID, let client = store.clients.first(where: { $0.id == id }) else {
            return R.stringLocalizable.doc_filter_all_clients()
        }
        return client.name
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.secondary)
            .textCase(nil)
            .padding(.leading, -8)
    }

    private func checkRow(_ title: String, isChecked: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                Spacer()
                if isChecked {
                    Image(R.image.ic_document_check)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func dateRow(_ title: String, date: Date?, field: DateField) -> some View {
        Button {
            withAnimation {
                editingDate = editingDate == field ? nil : field
                if field == .from, draft.fromDate == nil { draft.fromDate = Date() }
                if field == .to, draft.toDate == nil { draft.toDate = Date() }
            }
        } label: {
            valueRow(title, value: date?.dayMonthYearText ?? R.stringLocalizable.doc_filter_any_date())
        }
        .buttonStyle(.plain)
    }

    private func valueRow(_ title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            Image(R.image.ic_document_chevron_small)
        }
        .contentShape(Rectangle())
    }

    private func datePicker(_ selection: Binding<Date>) -> some View {
        DatePicker("", selection: selection, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(Color(R.color.color6A4DF5))
    }

    private func apply() {
        filters[kind] = draft
        app.navi.pop()
    }
}

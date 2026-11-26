//
//  FieldRecurringScreen.swift
//  Invoice
//
//  Invoice/Recurring (+ Repeat Options): schedule (repeat, start, end) and
//  delivery (send automatically, email to). "Save" applies, back discards.
//

import SwiftUI
import Factory

struct FieldRecurringScreen: View {
    @Injected(\.app) private var app
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @StateObject private var viewModel = FieldRecurringViewModel()

    @State private var expandedDate: DateRow?
    @State private var showsRepeat = false
    @State private var showsEnds = false
    @State private var showsEmail = false
    @State private var emailDraft = ""

    private enum DateRow {
        case start
        case end
    }

    var body: some View {
        VStack(spacing: 0) {
            FieldHeader(
                title: R.stringLocalizable.field_recurring_title(),
                actionTitle: R.stringLocalizable.save(),
                onBack: { app.navi.pop() },
                onAction: {
                    viewModel.save(into: editor)
                    app.navi.pop()
                }
            )

            List {
                Section {
                    FieldOptionRow(
                        title: R.stringLocalizable.field_repeat(),
                        value: viewModel.interval.fieldTitle,
                        style: .secondary,
                        showsChevron: true
                    ) {
                        showsRepeat = true
                    }
                    FieldDateRows(
                        title: R.stringLocalizable.field_recurring_starts(),
                        date: $viewModel.startDate,
                        isExpanded: isExpanded(.start),
                        valueText: Self.dayMonthYear,
                        style: .secondary,
                        showsChevron: true
                    )
                    FieldOptionRow(
                        title: R.stringLocalizable.field_recurring_ends(),
                        value: viewModel.endDate.map(Self.dayMonthYear) ?? R.stringLocalizable.field_repeat_never(),
                        style: expandedDate == .end ? .value : .secondary,
                        showsChevron: true
                    ) {
                        showsEnds = true
                    }
                    if expandedDate == .end, viewModel.endDate != nil {
                        DatePicker("", selection: endDate, in: viewModel.startDate..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                } header: {
                    sectionHeader(R.stringLocalizable.field_recurring_schedule())
                }

                Section {
                    Toggle(isOn: $viewModel.sendsAutomatically) {
                        Text(R.stringLocalizable.field_recurring_send_auto())
                            .font(.body)
                            .foregroundStyle(Color(R.color.color111118))
                    }
                    FieldOptionRow(
                        title: R.stringLocalizable.field_recurring_email_to(),
                        value: viewModel.email,
                        style: .secondary,
                        showsChevron: true
                    ) {
                        emailDraft = viewModel.email
                        showsEmail = true
                    }
                } header: {
                    sectionHeader(R.stringLocalizable.field_recurring_delivery())
                } footer: {
                    Text(viewModel.footer)
                }
            }
            .fieldListStyle()
        }
        .groupedScreenBackground()
        .fieldOptionsDialog(R.stringLocalizable.field_repeat(), isPresented: $showsRepeat) {
            ForEach(RepeatInterval.fieldSheetOptions, id: \.self) { interval in
                Button(interval.fieldTitle) { viewModel.interval = interval }
            }
        }
        .fieldOptionsDialog(R.stringLocalizable.field_recurring_ends(), isPresented: $showsEnds) {
            Button(R.stringLocalizable.field_repeat_never()) {
                viewModel.endDate = nil
                if expandedDate == .end { expandedDate = nil }
            }
            Button(R.stringLocalizable.field_recurring_ends_on_date()) {
                viewModel.endOnDate()
                withAnimation { expandedDate = .end }
            }
        }
        .alert(R.stringLocalizable.field_recurring_email_to(), isPresented: $showsEmail) {
            TextField(R.stringLocalizable.field_recurring_email_placeholder(), text: $emailDraft)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
            Button(R.stringLocalizable.save()) {
                viewModel.email = emailDraft.trimmingCharacters(in: .whitespaces)
            }
        }
        .onAppear { viewModel.load(from: editor.document) }
        .onChange(of: editor.document.id) { _ in viewModel.load(from: editor.document) }
        .trackScreen(.fieldRecurring)
    }

    /// "Nested" list header: aligned with the card edge, not the row text.
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.secondary)
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    private func isExpanded(_ row: DateRow) -> Binding<Bool> {
        Binding(
            get: { expandedDate == row },
            set: { expandedDate = $0 ? row : nil }
        )
    }

    private var endDate: Binding<Date> {
        Binding(
            get: { viewModel.endDate ?? viewModel.startDate },
            set: { viewModel.endDate = $0 }
        )
    }

    /// `01 Dec 2026`
    private static func dayMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

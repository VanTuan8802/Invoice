//
//  ExportDataScreen.swift
//  Invoice
//
//  Settings/Export: format, date range and which documents to include, then
//  share the generated CSV / PDF.
//

import SwiftUI
import Factory

struct ExportDataScreen: View {
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app
    @StateObject private var viewModel = ExportDataViewModel()

    @AppStorage(SettingsStorage.Key.exportFormat) private var format: ExportFormat = .csv
    @AppStorage(SettingsStorage.Key.exportRange) private var range: ExportRange = .thisMonth
    @AppStorage(SettingsStorage.Key.exportPaid) private var includePaid = true
    @AppStorage(SettingsStorage.Key.exportUnpaid) private var includeUnpaid = true
    @AppStorage(SettingsStorage.Key.exportOverdue) private var includeOverdue = true
    @AppStorage(SettingsStorage.Key.exportEstimates) private var includeEstimates = false

    private var options: ExportOptions {
        ExportOptions(format: format, range: range, paid: includePaid, unpaid: includeUnpaid,
                      overdue: includeOverdue, estimates: includeEstimates)
    }

    private var documents: [Document] {
        viewModel.documents(from: store, options: options)
    }

    var body: some View {
        let count = documents.count

        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_export_data(),
                            showBack: true,
                            backAction: { app.navi.pop() })

            Form {
                Section {
                    Picker(selection: $format) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.title).tag(format)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.large)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    Text(R.stringLocalizable.settings_format()).settingsSectionHeader()
                }

                Section {
                    Menu {
                        Picker(selection: $range) {
                            ForEach(ExportRange.allCases) { range in
                                Text(range.title).tag(range)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        SettingsMenuRowLabel(title: R.stringLocalizable.settings_date_range(), value: range.title)
                    }
                } header: {
                    Text(R.stringLocalizable.settings_range()).settingsSectionHeader()
                }

                Section {
                    toggle(R.stringLocalizable.settings_paid(), isOn: $includePaid)
                    toggle(R.stringLocalizable.settings_unpaid(), isOn: $includeUnpaid)
                    toggle(R.stringLocalizable.settings_overdue(), isOn: $includeOverdue)
                    toggle(R.stringLocalizable.settings_estimates(), isOn: $includeEstimates)
                } header: {
                    Text(R.stringLocalizable.settings_include()).settingsSectionHeader()
                } footer: {
                    Text(count == 1
                         ? R.stringLocalizable.settings_export_summary_one()
                         : R.stringLocalizable.settings_export_summary(count))
                        .settingsSectionFooter()
                }

                Section {
                    exportButton(count: count)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .settingsFormStyle(topMargin: 8, sectionSpacing: 24)
        }
        .groupedScreenBackground()
        .task(id: options) {
            viewModel.rebuildFile(documents: documents, options: options, currencyCode: store.currencyCode)
        }
        .trackScreen(.settingsExport)
    }

    @ViewBuilder
    private func exportButton(count: Int) -> some View {
        let title = count == 1
            ? R.stringLocalizable.settings_export_button_one()
            : R.stringLocalizable.settings_export_button(count)
        let label = Text(title)
            .font(.body.weight(.medium))
            .frame(maxWidth: .infinity)

        Group {
            if let url = viewModel.fileURL, count > 0 {
                ShareLink(item: url) { label }
            } else {
                Button {} label: { label }
                    .disabled(true)
            }
        }
        .modifier(ProminentCapsuleButton())
    }

    private func toggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(.label))
        }
        .tint(Color(.systemGreen))
    }
}

/// Large blue glass-prominent capsule (iOS 26), bordered-prominent before that.
private struct ProminentCapsuleButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        }
    }
}

#if DEBUG
#Preview {
    ExportDataScreen()
}
#endif

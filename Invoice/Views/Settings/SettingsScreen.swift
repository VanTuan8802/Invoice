//
//  SettingsScreen.swift
//  Invoice
//
//  Settings/Main: premium banner, then the Settings / About / Data groups.
//

import SwiftUI
import Factory

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    /// Observed so titles re-render after the language changes.
    @InjectedObject(\.appFlow) private var flow: AppFlowCoordinator
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(title: R.stringLocalizable.settings(), backAction: viewModel.back)

            List {
                Section {
                    SettingsPremiumBanner(action: viewModel.openPremium)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                Section {
                    row(R.image.ic_settings_business, R.color.colorFFEBD9, R.stringLocalizable.settings_business_info()) {
                        viewModel.open(.businessInfo)
                    }
                    row(R.image.ic_settings_template, R.color.colorDDF6F2, R.stringLocalizable.settings_template()) {
                        viewModel.openTemplate()
                    }
                    row(R.image.ic_settings_email, R.color.colorE3EEFF, R.stringLocalizable.settings_default_email()) {
                        viewModel.open(.defaultEmailMessage)
                    }
                    row(R.image.ic_settings_number, R.color.colorEEE9FF, R.stringLocalizable.settings_invoice_number()) {
                        viewModel.open(.invoiceNumber)
                    }
                    row(R.image.ic_settings_unit, R.color.colorDDF7EA, R.stringLocalizable.settings_unit()) {
                        viewModel.open(.unit)
                    }
                } header: {
                    Text(R.stringLocalizable.settings()).settingsSectionHeader()
                }

                Section {
                    row(R.image.ic_settings_language, R.color.colorDDF3FF, R.stringLocalizable.language()) {
                        viewModel.openLanguage()
                    }
                    ShareLink(item: viewModel.shareMessage) {
                        SettingsIconRow(icon: R.image.ic_settings_share,
                                        tileColor: Color(R.color.colorFFE6F3),
                                        title: R.stringLocalizable.common_share())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(Self.rowInsets)
                    row(R.image.ic_settings_rate, R.color.colorFFF2CC, R.stringLocalizable.settings_rate_us()) {
                        viewModel.rateApp()
                    }
                    row(R.image.ic_settings_privacy, R.color.colorE5E9FF, R.stringLocalizable.privacy_policy()) {
                        if let url = viewModel.policyURL { openURL(url) }
                    }
                } header: {
                    Text(R.stringLocalizable.about()).settingsSectionHeader()
                }

                Section {
                    dataRow(R.image.ic_settings_reminders, R.color.colorF59E0B, R.stringLocalizable.settings_reminders()) {
                        viewModel.open(.reminders)
                    }
                    dataRow(R.image.ic_settings_backup, R.color.color3B82F6, R.stringLocalizable.settings_backup_sync()) {
                        viewModel.open(.backup)
                    }
                    dataRow(R.image.ic_settings_export, R.color.color0FBA80, R.stringLocalizable.settings_export_data()) {
                        viewModel.open(.export)
                    }
                } header: {
                    Text(R.stringLocalizable.settings_section_data()).settingsSectionHeader()
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.defaultMinListRowHeight, 52)
        }
        .groupedScreenBackground()
        .trackScreen(.settings)
    }

    // MARK: Rows

    /// 32pt tile + 10pt top/bottom = the design's 52pt rows, tile 16pt from the card edge.
    private static let rowInsets = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)

    private func row(_ icon: RswiftResources.ImageResource,
                     _ tile: RswiftResources.ColorResource,
                     _ title: String,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsIconRow(icon: icon, tileColor: Color(tile), title: title)
        }
        .buttonStyle(.plain)
        .listRowInsets(Self.rowInsets)
    }

    /// Data group: translucent tint tiles (16% of the glyph colour), 9pt corners.
    private func dataRow(_ icon: RswiftResources.ImageResource,
                         _ tint: RswiftResources.ColorResource,
                         _ title: String,
                         action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsIconRow(icon: icon, tileColor: Color(tint).opacity(0.16), title: title, tileCornerRadius: 9)
        }
        .buttonStyle(.plain)
        .listRowInsets(Self.rowInsets)
    }
}

#if DEBUG
#Preview {
    SettingsScreen()
}
#endif

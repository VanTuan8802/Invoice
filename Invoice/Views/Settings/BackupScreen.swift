//
//  BackupScreen.swift
//  Invoice
//
//  Settings/Backup (+ Restore Alert). UI only for now: "Back Up Now" records a
//  local timestamp and an estimated size; restoring is not wired to iCloud yet.
//

import SwiftUI
import Factory

struct BackupScreen: View {
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.backupToICloud) private var backupToICloud = true
    /// Seconds since 1970; 0 = never backed up.
    @AppStorage(SettingsStorage.Key.lastBackupDate) private var lastBackupDate: Double = 0
    @AppStorage(SettingsStorage.Key.lastBackupSize) private var lastBackupSize = 0

    @State private var isBackingUp = false
    @State private var showsRestoreAlert: Bool

    /// - Parameter showsRestoreAlert: open with the restore confirmation shown.
    init(showsRestoreAlert: Bool = false) {
        _showsRestoreAlert = State(initialValue: showsRestoreAlert)
    }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_backup_sync(),
                            showBack: true,
                            backAction: { app.navi.pop() })

            Form {
                Section {
                    Toggle(isOn: $backupToICloud) {
                        Text(R.stringLocalizable.settings_backup_icloud())
                            .font(.body)
                            .foregroundStyle(Color(.label))
                    }
                    .tint(Color(.systemGreen))
                } footer: {
                    Text(R.stringLocalizable.settings_backup_footer())
                        .settingsSectionFooter()
                }

                Section {
                    infoRow(R.stringLocalizable.settings_backup_date(), value: lastBackupText)
                    infoRow(R.stringLocalizable.settings_backup_size(), value: sizeText)
                } header: {
                    Text(R.stringLocalizable.settings_last_backup()).settingsSectionHeader()
                }

                Section {
                    Button(action: backUpNow) {
                        HStack {
                            Text(R.stringLocalizable.settings_backup_now())
                                .font(.body)
                                .foregroundStyle(Color(R.color.color6A4DF5))
                            Spacer(minLength: 8)
                            if isBackingUp {
                                ProgressView()
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isBackingUp)

                    Button {
                        showsRestoreAlert = true
                    } label: {
                        HStack {
                            Text(R.stringLocalizable.settings_restore())
                                .font(.body)
                                .foregroundStyle(Color(.label))
                            Spacer(minLength: 8)
                            SettingsChevron()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .settingsFormStyle(topMargin: 8, sectionSpacing: 32)
        }
        .groupedScreenBackground()
        .alert(R.stringLocalizable.settings_restore_title(), isPresented: $showsRestoreAlert) {
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
            Button(R.stringLocalizable.settings_restore_action()) {
                // Restoring from iCloud is not implemented yet (UI only).
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text(R.stringLocalizable.settings_restore_message())
        }
        .trackScreen(.settingsBackup)
    }

    // MARK: Values

    private var lastBackupText: String {
        guard lastBackupDate > 0 else { return R.stringLocalizable.settings_backup_never() }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: OnboardingStore().currentLanguage.rawValue)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: Date(timeIntervalSince1970: lastBackupDate))
    }

    private var sizeText: String {
        ByteCountFormatter.string(fromByteCount: Int64(lastBackupSize), countStyle: .file)
    }

    /// Rough size of what a backup would contain (documents, contacts, items, logo).
    private var estimatedBackupSize: Int {
        let documents = (store.invoices.count + store.estimates.count) * 48_000
        let contacts = store.clients.count * 2_000 + store.items.count * 1_000
        return documents + contacts + (store.business.logoData?.count ?? 0)
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(.label))
            Spacer(minLength: 8)
            Text(value)
                .font(.body)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(1)
        }
    }

    private func backUpNow() {
        isBackingUp = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            lastBackupDate = Date().timeIntervalSince1970
            lastBackupSize = estimatedBackupSize
            isBackingUp = false
        }
    }
}

#if DEBUG
#Preview {
    BackupScreen()
}
#endif

//
//  SettingsRoute.swift
//  Invoice
//
//  Settings screens (`Destination.settings`). Owned by the Settings feature.
//

import SwiftUI

enum SettingsRoute: Hashable {
    /// Settings/Main
    case main
    /// Settings/Business Info
    case businessInfo
    /// Settings/Default Email Message
    case defaultEmailMessage
    /// Settings/Invoice Number (+ Edited)
    case invoiceNumber
    /// Settings/Unit (+ Currency Picker)
    case unit
    /// Settings/Unit opened with the currency picker sheet presented.
    case unitCurrencyPicker
    /// Settings/Reminders
    case reminders
    /// Settings/Backup (+ Restore Alert)
    case backup
    /// Settings/Backup opened with the restore confirmation shown.
    case backupRestoreAlert
    /// Settings/Export
    case export

    var identifier: String {
        switch self {
        case .main:                return "settings.main"
        case .businessInfo:        return "settings.businessInfo"
        case .defaultEmailMessage: return "settings.defaultEmailMessage"
        case .invoiceNumber:       return "settings.invoiceNumber"
        case .unit:                return "settings.unit"
        case .unitCurrencyPicker:  return "settings.unit.currencyPicker"
        case .reminders:           return "settings.reminders"
        case .backup:              return "settings.backup"
        case .backupRestoreAlert:  return "settings.backup.restoreAlert"
        case .export:              return "settings.export"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .main:                SettingsScreen()
        case .businessInfo:        BusinessInfoScreen()
        case .defaultEmailMessage: DefaultEmailMessageScreen()
        case .invoiceNumber:       InvoiceNumberScreen()
        case .unit:                UnitScreen()
        case .unitCurrencyPicker:  UnitScreen(showsCurrencyPicker: true)
        case .reminders:           RemindersScreen()
        case .backup:              BackupScreen()
        case .backupRestoreAlert:  BackupScreen(showsRestoreAlert: true)
        case .export:              ExportDataScreen()
        }
    }

    #if DEBUG
    static var debugPreviews: [String: SettingsRoute] {
        let routes: [SettingsRoute] = [
            .main, .businessInfo, .defaultEmailMessage, .invoiceNumber, .unit,
            .unitCurrencyPicker, .reminders, .backup, .backupRestoreAlert, .export,
        ]
        return Dictionary(uniqueKeysWithValues: routes.map { ($0.identifier, $0) })
    }
    #endif
}

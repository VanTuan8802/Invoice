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
    /// Settings/Reminders
    case reminders
    /// Settings/Backup (+ Restore Alert)
    case backup
    /// Settings/Export
    case export

    var identifier: String {
        switch self {
        case .main:                return "settings.main"
        case .businessInfo:        return "settings.businessInfo"
        case .defaultEmailMessage: return "settings.defaultEmailMessage"
        case .invoiceNumber:       return "settings.invoiceNumber"
        case .unit:                return "settings.unit"
        case .reminders:           return "settings.reminders"
        case .backup:              return "settings.backup"
        case .export:              return "settings.export"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .main:
            SettingsScreen()
        case .businessInfo, .defaultEmailMessage, .invoiceNumber, .unit, .reminders, .backup, .export:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: SettingsRoute] {
        ["settings.main": .main]
    }
    #endif
}

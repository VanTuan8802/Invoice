//
//  SettingsStorage.swift
//  Invoice
//
//  Settings-only values that have no field in `Domain/Models.swift`, persisted in
//  `UserDefaults` and read with `@AppStorage(SettingsStorage.Key.x)`.
//

import Foundation

enum SettingsStorage {
    enum Key {
        // Business Info (extra fields not in `BusinessProfile`)
        static let businessOwnerName = "settings.business.ownerName"
        static let businessNumber = "settings.business.number"
        static let businessMobile = "settings.business.mobile"

        // Invoice Number
        static let invoiceNumber = "settings.invoiceNumber"
        static let estimateNumber = "settings.estimateNumber"

        // Unit
        static let dateFormat = "settings.dateFormat"

        // Default Email Message
        static let defaultEmailMessage = "settings.defaultEmailMessage"

        // Reminders
        static let paymentReminders = "settings.reminders.enabled"
        static let reminderDaysBefore = "settings.reminders.daysBefore"
        static let reminderOnDueDate = "settings.reminders.onDueDate"
        static let reminderEveryDaysAfter = "settings.reminders.everyDaysAfter"
        static let notifyPaid = "settings.reminders.notifyPaid"
        static let notifyOverdue = "settings.reminders.notifyOverdue"
        static let notifyRecurringSent = "settings.reminders.notifyRecurringSent"

        // Backup & Sync
        static let backupToICloud = "settings.backup.iCloud"
        static let lastBackupDate = "settings.backup.lastDate"
        static let lastBackupSize = "settings.backup.lastSize"

        // Export
        static let exportFormat = "settings.export.format"
        static let exportRange = "settings.export.range"
        static let exportPaid = "settings.export.paid"
        static let exportUnpaid = "settings.export.unpaid"
        static let exportOverdue = "settings.export.overdue"
        static let exportEstimates = "settings.export.estimates"
    }

    /// Date patterns offered on the Unit screen.
    static let dateFormats = ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "dd.MM.yyyy"]
    static let defaultDateFormat = dateFormats[0]

    /// "Before Due Date" choices, in days.
    static let reminderDaysBeforeOptions = [1, 2, 3, 5, 7, 14]
    /// "After Due Date" repeat choices, in days.
    static let reminderEveryDaysOptions = [3, 7, 14, 30]
}

/// Validation shared by the Invoice Number screen and anyone reading the stored values.
enum DocumentNumberRule {
    /// Empty means "use the automatic number"; otherwise it needs a letter and a digit.
    static func isValid(_ value: String) -> Bool {
        value.isEmpty || (value.contains(where: \.isLetter) && value.contains(where: \.isNumber))
    }
}

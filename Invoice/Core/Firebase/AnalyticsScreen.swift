import Foundation

/// Stable `rawValue` strings for Firebase Analytics `screen_view`.
/// IMPORTANT: rawValue đã release → KHÔNG đổi (dashboard/BigQuery phụ thuộc).
///
/// Các màn của Invoice. Thêm case khi thêm màn mới — mỗi chức năng thêm vào đúng
/// khu của mình (snake_case rawValue).
enum AnalyticsScreen: String {
    // MARK: Onboarding & premium
    case splash
    case language                                  // first-launch language picker
    case intro


    // MARK: Home
    case home


    // MARK: Documents (invoice & estimate)


    // MARK: Document fields


    // MARK: Client & item


    // MARK: Reports


    // MARK: Settings
    case settings
    case settingsLanguage = "settings_language"    // language screen opened from Settings
    case settingsBusinessInfo = "settings_business_info"
    case settingsInvoiceNumber = "settings_invoice_number"
    case settingsUnit = "settings_unit"
    case settingsCurrencyPicker = "settings_currency_picker"
    case settingsDefaultEmail = "settings_default_email"
    case settingsReminders = "settings_reminders"
    case settingsBackup = "settings_backup"
    case settingsExport = "settings_export"
}

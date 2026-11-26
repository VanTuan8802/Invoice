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
}

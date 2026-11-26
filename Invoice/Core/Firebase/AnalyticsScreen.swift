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
    case welcome
    case businessDetails = "business_details"
    case businessLogo = "business_logo"
    case onboardingTemplate = "onboarding_template"
    case premiumPlans = "premium_plans"
    case premiumSuccess = "premium_success"
    case allSet = "all_set"


    // MARK: Home
    case home


    // MARK: Documents (invoice & estimate)
    case invoiceList = "invoice_list"
    case estimateList = "estimate_list"
    case documentSearch = "document_search"
    case documentFilter = "document_filter"
    case documentEdit = "document_edit"
    case documentPreview = "document_preview"
    case documentHistory = "document_history"
    case documentShare = "document_share"
    case documentMarkAsPaid = "document_mark_as_paid"
    case documentSignature = "document_signature"
    case documentPhoto = "document_photo"


    // MARK: Document fields
    case fieldInfo = "field_info"
    case fieldTemplate = "field_template"
    case fieldTemplateDefault = "field_template_default"   // default template, opened from Settings
    case fieldEmail = "field_email"
    case fieldEmailContacts = "field_email_contacts"
    case fieldDiscount = "field_discount"
    case fieldTax = "field_tax"
    case fieldPayments = "field_payments"
    case fieldPayment = "field_payment"
    case fieldPaymentInfo = "field_payment_info"
    case fieldNote = "field_note"
    case fieldRecurring = "field_recurring"


    // MARK: Client & item
    case clientList = "client_list"
    case clientPicker = "client_picker"                // client list opened from the invoice editor
    case clientDetail = "client_detail"
    case clientEdit = "client_edit"
    case itemList = "item_list"
    case itemPicker = "item_picker"                    // "My Items" opened from the invoice editor
    case itemEdit = "item_edit"                        // catalog item ("My Items")
    case itemLineItem = "item_line_item"               // line item on the open document


    // MARK: Reports
    case reportsOverview = "reports_overview"
    case reportsUnpaid = "reports_unpaid"


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

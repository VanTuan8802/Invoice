//
//  DocumentDisplay.swift
//  Invoice
//
//  Localized titles, status and date/term texts shared by the invoice & estimate
//  screens (list, search, editor, preview).
//

import SwiftUI

// MARK: - Kind

extension DocumentKind {
    /// "Invoice" / "Estimate" (toolbar titles).
    var title: String {
        self == .invoice ? R.stringLocalizable.doc_invoice_title() : R.stringLocalizable.doc_estimate_title()
    }

    /// "Invoice Info" / "Estimate Info" section header in the editor.
    var infoTitle: String {
        self == .invoice ? R.stringLocalizable.doc_invoice_info() : R.stringLocalizable.doc_estimate_info()
    }

    var searchPlaceholder: String {
        self == .invoice
            ? R.stringLocalizable.doc_search_placeholder_invoice()
            : R.stringLocalizable.doc_search_placeholder_estimate()
    }

    var emptyTitle: String {
        self == .invoice ? R.stringLocalizable.doc_empty_invoice_title() : R.stringLocalizable.doc_empty_estimate_title()
    }

    var emptyMessage: String {
        self == .invoice ? R.stringLocalizable.doc_empty_invoice_message() : R.stringLocalizable.doc_empty_estimate_message()
    }

    var emptyIllustration: RswiftResources.ImageResource {
        self == .invoice ? R.image.illus_invoice : R.image.illus_estimate
    }

    /// Soft tile behind the empty-state illustration.
    var emptyTileColor: Color {
        self == .invoice ? Color(R.color.colorEEE9FF) : Color(R.color.colorE9F2FF)
    }

    /// "Show 12 Invoices" on the filter screen.
    func showCountTitle(_ count: Int) -> String {
        self == .invoice
            ? R.stringLocalizable.doc_filter_show_invoices(count)
            : R.stringLocalizable.doc_filter_show_estimates(count)
    }

    /// Heading printed on the document preview ("INVOICE" / "ESTIMATE").
    var previewHeading: String {
        self == .invoice ? R.stringLocalizable.doc_preview_invoice() : R.stringLocalizable.doc_preview_estimate()
    }

    var listScreen: AnalyticsScreen {
        self == .invoice ? .invoiceList : .estimateList
    }
}

// MARK: - Status shown in lists / chips

/// Paid / Unpaid / Overdue as the user sees it (drafts count as unpaid).
enum DocumentDisplayStatus: String, Hashable, CaseIterable, Identifiable {
    case paid
    case unpaid
    case overdue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paid:    return R.stringLocalizable.doc_status_paid()
        case .unpaid:  return R.stringLocalizable.doc_status_unpaid()
        case .overdue: return R.stringLocalizable.doc_status_overdue()
        }
    }

    /// Chip label color.
    var tint: Color {
        switch self {
        case .paid:    return Color(R.color.color1A8038)
        case .unpaid:  return Color(R.color.colorB26100)
        case .overdue: return Color(R.color.colorD1211A)
        }
    }

    /// Chip background (system green / orange / red at 16%).
    var background: Color {
        switch self {
        case .paid:    return Color(.systemGreen).opacity(0.16)
        case .unpaid:  return Color(.systemOrange).opacity(0.16)
        case .overdue: return Color(.systemRed).opacity(0.16)
        }
    }
}

// MARK: - Document texts

extension Document {
    var displayStatus: DocumentDisplayStatus {
        if status == .paid { return .paid }
        return isOverdue ? .overdue : .unpaid
    }

    /// Client name, or "No Client".
    var clientDisplayName: String {
        guard let name = client?.name, !name.isEmpty else { return R.stringLocalizable.doc_no_client() }
        return name
    }

    /// Whole days from today until the due date (negative when overdue).
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    /// "Due in 4 days", "Due Today", "Overdue by 2 days", "Paid on 05/11/2024".
    var dueStatusText: String {
        if status == .paid {
            return R.stringLocalizable.doc_paid_on((paidDate ?? Date()).numericDateText)
        }
        let days = daysUntilDue
        switch days {
        case 0:        return R.stringLocalizable.doc_due_today()
        case 1:        return R.stringLocalizable.doc_due_tomorrow()
        case 2...:     return R.stringLocalizable.doc_due_in_days(days)
        case -1:       return R.stringLocalizable.doc_overdue_one_day()
        default:       return R.stringLocalizable.doc_overdue_days(-days)
        }
    }

    /// Search result subtitle: "INV0007 · Due 12 Nov 2026" / "INV0001 · Paid 02 Nov 2026".
    var resultSubtitle: String {
        if status == .paid {
            return R.stringLocalizable.doc_result_paid(number, (paidDate ?? dueDate).dayMonthYearText)
        }
        return R.stringLocalizable.doc_result_due(number, dueDate.dayMonthYearText)
    }
}

extension PaymentTerms {
    /// Days for the "Net N" terms.
    var netDays: Int? {
        switch self {
        case .net7:  return 7
        case .net15: return 15
        case .net30: return 30
        case .net45: return 45
        case .net60: return 60
        case .dueOnReceipt, .custom: return nil
        }
    }

    var title: String {
        if let days = netDays { return R.stringLocalizable.doc_terms_net_days(days) }
        return self == .dueOnReceipt
            ? R.stringLocalizable.doc_terms_due_on_receipt()
            : R.stringLocalizable.doc_terms_custom()
    }
}

extension Date {
    /// `12 Nov 2026`
    var dayMonthYearText: String {
        formatted(.dateTime.day(.twoDigits).month(.abbreviated).year())
    }

    /// `11:24:25`
    var timeWithSecondsText: String {
        formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits))
    }
}

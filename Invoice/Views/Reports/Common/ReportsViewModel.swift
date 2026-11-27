//
//  ReportsViewModel.swift
//  Invoice
//
//  Figures for Reports/Overview and Reports/Unpaid, computed from
//  `DataStore.invoices` for the selected period (Week / Month / Year, persisted
//  so the Unpaid screen shows the same period as the Overview):
//  - total revenue = sum of invoice totals issued in the period, compared with
//    the previous period;
//  - bars = the last six periods' revenue;
//  - Paid / Unpaid / Overdue counts and amounts (open balance for unpaid ones);
//  - top clients by revenue.
//

import Foundation
import Factory

enum ReportsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:  return R.stringLocalizable.reports_period_week()
        case .month: return R.stringLocalizable.reports_period_month()
        case .year:  return R.stringLocalizable.reports_period_year()
        }
    }

    fileprivate var component: Calendar.Component {
        switch self {
        case .week:  return .weekOfYear
        case .month: return .month
        case .year:  return .year
        }
    }
}

struct ReportsBar: Identifiable {
    /// Offset from the current period (0 = current, -1 = previous…).
    let id: Int
    let label: String
    let amount: Double
    var isCurrent: Bool { id == 0 }
}

struct ReportsStatusSummary {
    let count: Int
    let amount: Decimal
}

struct ReportsClientTotal: Identifiable {
    let client: Client
    let total: Decimal
    var id: UUID { client.id }
}

@MainActor
final class ReportsViewModel: ObservableObject {
    private static let periodKey = "reports.period"
    private static let barCount = 6

    @Published var period: ReportsPeriod {
        didSet { UserDefaults.standard.set(period.rawValue, forKey: Self.periodKey) }
    }

    private let store: DataStore
    private let now: Date
    private let locale: Locale
    private let calendar: Calendar

    init(now: Date = Date()) {
        store = Container.shared.dataStore()
        period = ReportsPeriod(rawValue: UserDefaults.standard.string(forKey: Self.periodKey) ?? "") ?? .month
        self.now = now
        locale = Locale(identifier: OnboardingStore().currentLanguage.rawValue)
        var calendar = Calendar.current
        calendar.locale = locale
        self.calendar = calendar
    }

    var currencyCode: String { store.currencyCode }

    // MARK: Revenue

    var totalRevenue: Decimal { Self.sum(invoices(offset: 0)) }

    /// "+8.2% vs October", or `nil` when there is nothing to compare with.
    var changeText: String? {
        let previous = Self.sum(invoices(offset: -1))
        guard previous != 0 else { return nil }
        let ratio = (totalRevenue - previous) / previous
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = locale
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.positivePrefix = formatter.plusSign + formatter.positivePrefix
        let percent = formatter.string(from: ratio as NSDecimalNumber) ?? ""
        return R.stringLocalizable.reports_change_vs(percent, previousPeriodName)
    }

    var isChangePositive: Bool {
        totalRevenue >= Self.sum(invoices(offset: -1))
    }

    var bars: [ReportsBar] {
        (1 - Self.barCount...0).map { offset in
            ReportsBar(id: offset,
                       label: label(offset: offset),
                       amount: NSDecimalNumber(decimal: Self.sum(invoices(offset: offset))).doubleValue)
        }
    }

    // MARK: Status

    var paid: ReportsStatusSummary {
        let paid = invoices(offset: 0).filter { $0.status == .paid }
        return ReportsStatusSummary(count: paid.count, amount: Self.sum(paid))
    }

    var unpaid: ReportsStatusSummary { Self.openSummary(unpaidInvoices) }

    var overdue: ReportsStatusSummary { Self.openSummary(overdueInvoices) }

    /// Reports/Unpaid rows: overdue first, then unpaid; biggest balance first.
    var outstandingInvoices: [Document] {
        let byBalance: (Document, Document) -> Bool = { $0.balance > $1.balance }
        return overdueInvoices.sorted(by: byBalance) + unpaidInvoices.sorted(by: byBalance)
    }

    var outstandingSummary: ReportsStatusSummary { Self.openSummary(outstandingInvoices) }

    func isOverdue(_ invoice: Document) -> Bool {
        invoice.status == .overdue || invoice.isOverdue
    }

    // MARK: Clients

    var topClients: [ReportsClientTotal] {
        var totals: [UUID: ReportsClientTotal] = [:]
        for invoice in invoices(offset: 0) {
            guard let client = invoice.client else { continue }
            let current = totals[client.id]?.total ?? 0
            totals[client.id] = ReportsClientTotal(client: client, total: current + invoice.total)
        }
        return totals.values
            .sorted { $0.total > $1.total }
            .prefix(3)
            .map { $0 }
    }

    // MARK: Text

    func invoiceCountText(_ count: Int) -> String {
        count == 1
            ? R.stringLocalizable.reports_invoice_count_one(count)
            : R.stringLocalizable.reports_invoice_count_other(count)
    }

    /// "INV0007 · Due 12 Nov 2026"
    func dueText(for invoice: Document) -> String {
        R.stringLocalizable.reports_due(invoice.number, dateText(invoice.dueDate))
    }

    /// Message shared by "Send Reminders to All": one reminder per invoice.
    var reminderMessage: String {
        outstandingInvoices.map { invoice in
            R.stringLocalizable.reports_reminder_message(
                invoice.client?.name ?? R.stringLocalizable.client_no_client(),
                invoice.number,
                invoice.balance.currencyText(code: currencyCode),
                dateText(invoice.dueDate)
            )
        }
        .joined(separator: "\n\n")
    }

    // MARK: Private

    private var unpaidInvoices: [Document] {
        invoices(offset: 0).filter { $0.status != .paid && !isOverdue($0) }
    }

    private var overdueInvoices: [Document] {
        invoices(offset: 0).filter { $0.status != .paid && isOverdue($0) }
    }

    /// Invoices issued in the period `offset` periods away from the current one.
    private func invoices(offset: Int) -> [Document] {
        guard let interval = interval(offset: offset) else { return [] }
        return store.invoices.filter { $0.issueDate >= interval.start && $0.issueDate < interval.end }
    }

    private func interval(offset: Int) -> DateInterval? {
        guard let date = calendar.date(byAdding: period.component, value: offset, to: now) else { return nil }
        return calendar.dateInterval(of: period.component, for: date)
    }

    /// Bar caption: "3 Nov" (week), "Nov" (month), "2026" (year).
    private func label(offset: Int) -> String {
        guard let start = interval(offset: offset)?.start else { return "" }
        switch period {
        case .week:  return start.formatted(.dateTime.day().month(.abbreviated).locale(locale))
        case .month: return start.formatted(.dateTime.month(.abbreviated).locale(locale))
        case .year:  return start.formatted(.dateTime.year().locale(locale))
        }
    }

    /// "last week" / "October" / "2025"
    private var previousPeriodName: String {
        guard let start = interval(offset: -1)?.start else { return "" }
        switch period {
        case .week:  return R.stringLocalizable.reports_last_week()
        case .month: return start.formatted(.dateTime.month(.wide).locale(locale))
        case .year:  return start.formatted(.dateTime.year().locale(locale))
        }
    }

    private func dateText(_ date: Date) -> String {
        date.formatted(.dateTime.day(.twoDigits).month(.abbreviated).year().locale(locale))
    }

    private static func sum(_ invoices: [Document]) -> Decimal {
        invoices.reduce(0) { $0 + $1.total }
    }

    private static func openSummary(_ invoices: [Document]) -> ReportsStatusSummary {
        ReportsStatusSummary(count: invoices.count, amount: invoices.reduce(0) { $0 + $1.balance })
    }
}

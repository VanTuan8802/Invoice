//
//  ExportDataViewModel.swift
//  Invoice
//
//  Filters documents for Settings/Export and writes the CSV / PDF file that the
//  export button shares.
//

import Foundation
import UIKit

enum ExportFormat: String, CaseIterable, Identifiable {
    case csv
    case pdf

    var id: String { rawValue }

    var title: String {
        switch self {
        case .csv: return R.stringLocalizable.settings_format_csv()
        case .pdf: return R.stringLocalizable.settings_format_pdf()
        }
    }
}

enum ExportRange: String, CaseIterable, Identifiable {
    case thisMonth
    case lastMonth
    case thisYear
    case allTime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thisMonth: return R.stringLocalizable.settings_range_this_month()
        case .lastMonth: return R.stringLocalizable.settings_range_last_month()
        case .thisYear:  return R.stringLocalizable.settings_range_this_year()
        case .allTime:   return R.stringLocalizable.settings_range_all()
        }
    }

    /// `nil` = no date limit.
    func interval(now: Date = Date(), calendar: Calendar = .current) -> DateInterval? {
        switch self {
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)
        case .lastMonth:
            let previous = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.dateInterval(of: .month, for: previous)
        case .thisYear:
            return calendar.dateInterval(of: .year, for: now)
        case .allTime:
            return nil
        }
    }
}

struct ExportOptions: Hashable {
    var format: ExportFormat
    var range: ExportRange
    var paid: Bool
    var unpaid: Bool
    var overdue: Bool
    var estimates: Bool

    func includes(_ document: Document) -> Bool {
        if let interval = range.interval(), !interval.contains(document.issueDate) { return false }
        if document.kind == .estimate { return estimates }
        if document.status == .paid { return paid }
        if document.isOverdue { return overdue }
        return unpaid
    }
}

@MainActor
final class ExportDataViewModel: ObservableObject {
    /// The file the export button shares (rebuilt whenever the options change).
    @Published private(set) var fileURL: URL?

    func documents(from store: DataStore, options: ExportOptions) -> [Document] {
        (store.invoices + store.estimates)
            .filter(options.includes)
            .sorted { $0.issueDate > $1.issueDate }
    }

    func rebuildFile(documents: [Document], options: ExportOptions, currencyCode: String) {
        guard !documents.isEmpty else {
            fileURL = nil
            return
        }
        let directory = FileManager.default.temporaryDirectory
        switch options.format {
        case .csv:
            let url = directory.appendingPathComponent("invoices.csv")
            let csv = Self.csv(documents, currencyCode: currencyCode)
            fileURL = (try? csv.write(to: url, atomically: true, encoding: .utf8)) == nil ? nil : url
        case .pdf:
            let url = directory.appendingPathComponent("invoices.pdf")
            let data = Self.pdf(documents, currencyCode: currencyCode)
            fileURL = (try? data.write(to: url, options: .atomic)) == nil ? nil : url
        }
    }

    // MARK: File builders

    private static func isoDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func status(_ document: Document) -> String {
        if document.kind == .estimate { return DocumentKind.estimate.rawValue }
        if document.status == .paid { return DocumentStatus.paid.rawValue }
        if document.isOverdue { return DocumentStatus.overdue.rawValue }
        return document.status.rawValue
    }

    /// Machine-readable CSV (column ids, ISO dates, plain decimals).
    private static func csv(_ documents: [Document], currencyCode: String) -> String {
        func field(_ value: String) -> String {
            "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        let columns = ["number", "type", "client", "issue_date", "due_date", "status", "total", "balance", "currency"]
        var lines = [columns.joined(separator: ",")]
        for document in documents {
            lines.append([
                field(document.number),
                document.kind.rawValue,
                field(document.client?.name ?? ""),
                isoDate(document.issueDate),
                isoDate(document.dueDate),
                status(document),
                "\(document.total)",
                "\(document.balance)",
                currencyCode,
            ].joined(separator: ","))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Simple A4 list: title, then one line per document.
    private static func pdf(_ documents: [Document], currencyCode: String) -> Data {
        let page = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 40
        let lineHeight: CGFloat = 22
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
        let rowAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]

        return UIGraphicsPDFRenderer(bounds: page).pdfData { context in
            var y = page.maxY
            func newPage() {
                context.beginPage()
                y = margin
            }
            newPage()
            R.stringLocalizable.settings_export_data().draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
            y += 40
            for document in documents {
                if y + lineHeight > page.maxY - margin { newPage() }
                let columns = [
                    document.number,
                    document.client?.name ?? "",
                    document.issueDate.numericDateText,
                    document.total.currencyText(code: currencyCode),
                ]
                let widths: [CGFloat] = [110, 200, 90, 115]
                var x = margin
                for (text, width) in zip(columns, widths) {
                    (text as NSString).draw(in: CGRect(x: x, y: y, width: width - 8, height: lineHeight),
                                            withAttributes: rowAttributes)
                    x += width
                }
                y += lineHeight
            }
        }
    }
}

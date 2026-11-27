//
//  ReportsComponents.swift
//  Invoice
//
//  Sub-views of the Reports screens: revenue card with the bar chart, list
//  section header, status / client / invoice rows, the Unpaid/Overdue chip and
//  the prominent "Send Reminders to All" button style.
//

import SwiftUI
import Charts

// MARK: - Revenue card

/// "Total Revenue  $12,480.00  +8.2% vs October" + six-period bar chart.
struct ReportsRevenueCard: View {
    let total: String
    let change: String?
    let isChangePositive: Bool
    let bars: [ReportsBar]
    /// Accessibility names of the chart axes (already localized).
    let periodName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(R.stringLocalizable.reports_total_revenue())
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
            Text(total)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if let change {
                Text(change)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color(isChangePositive ? R.color.color1A8038 : R.color.colorD1211A))
            }
            ReportsBarChart(bars: bars, periodName: periodName)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ReportsBarChart: View {
    let bars: [ReportsBar]
    let periodName: String

    private var maxAmount: Double { bars.map(\.amount).max() ?? 0 }

    var body: some View {
        Chart(bars) { bar in
            BarMark(
                x: .value(periodName, bar.label),
                y: .value(R.stringLocalizable.reports_total_revenue(), bar.amount),
                width: .fixed(36)
            )
            .cornerRadius(9)
            .foregroundStyle(Color(R.color.color6A4DF5).opacity(bar.isCurrent ? 1 : 0.28))
        }
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...max(maxAmount, 1))
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(height: 132)
    }
}

// MARK: - List pieces

/// "Status", "Top Clients", "6 invoices · $3,160.00"
struct ReportsSectionHeader: View {
    /// Already-localized text.
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color.secondary)
            .textCase(nil)
    }
}

/// "Paid · 18 invoices · $9,320.00"
struct ReportsStatusRow: View {
    let title: String
    var titleColor: Color = Color.primary
    let subtitle: String
    let amount: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(titleColor)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer(minLength: 8)
            Text(amount)
                .font(.headline)
                .foregroundStyle(Color.primary)
        }
        .contentShape(Rectangle())
    }
}

/// "Walt Disney Company   $4,210.00 ›"
struct ReportsClientRow: View {
    let name: String
    let amount: String

    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.body)
                .foregroundStyle(Color.primary)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(amount)
                .font(.body)
                .foregroundStyle(Color.secondary)
            Image(R.image.ic_reports_chevron)
        }
        .contentShape(Rectangle())
    }
}

/// Reports/Unpaid row: client + "INV0007 · Due 12 Nov 2026", amount + chip.
struct ReportsInvoiceRow: View {
    let clientName: String
    let subtitle: String
    let amount: String
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(.body)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                ReportsStatusChip(isOverdue: isOverdue)
            }
        }
        .contentShape(Rectangle())
    }
}

/// Red "Overdue" / orange "Unpaid" pill.
struct ReportsStatusChip: View {
    let isOverdue: Bool

    var body: some View {
        Text(isOverdue ? R.stringLocalizable.reports_overdue() : R.stringLocalizable.reports_unpaid())
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color(isOverdue ? R.color.colorD1211A : R.color.colorB26100))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill((isOverdue ? Color(.systemRed) : Color(.systemOrange)).opacity(0.16))
            )
    }
}

// MARK: - Prominent button

extension View {
    /// Full-width "Glass Prominent" large button (iOS 26), blue capsule before.
    @ViewBuilder
    func reportsProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self
                .buttonStyle(.glassProminent)
                .controlSize(.large)
        } else {
            self.buttonStyle(ReportsProminentFallbackStyle())
        }
    }
}

private struct ReportsProminentFallbackStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color(R.color.colorFFFFFF))
            .frame(height: 50)
            .background(Capsule().fill(Color.accentColor))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

//
//  ReportsOverviewScreen.swift
//  Invoice
//
//  Reports/Overview: Week / Month / Year picker, total revenue with the change
//  vs the previous period and a six-period bar chart, Paid / Unpaid / Overdue
//  status (Unpaid & Overdue open Reports/Unpaid) and Top Clients (open the
//  client's info).
//

import SwiftUI
import Factory

struct ReportsOverviewScreen: View {
    @StateObject private var viewModel = ReportsViewModel()
    /// Observed so the figures refresh when invoices change.
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(title: R.stringLocalizable.reports_title(), backAction: { app.navi.pop() })

            List {
                Section {
                    Picker(R.stringLocalizable.reports_title(), selection: $viewModel.period) {
                        ForEach(ReportsPeriod.allCases) { period in
                            Text(period.title).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .controlSize(.large)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section {
                    ReportsRevenueCard(
                        total: viewModel.totalRevenue.currencyText(code: viewModel.currencyCode),
                        change: viewModel.changeText,
                        isChangePositive: viewModel.isChangePositive,
                        bars: viewModel.bars,
                        periodName: viewModel.period.title
                    )
                    .listRowInsets(EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18))
                }

                Section {
                    statusRows
                } header: {
                    ReportsSectionHeader(title: R.stringLocalizable.reports_status())
                }

                if !viewModel.topClients.isEmpty {
                    Section {
                        ForEach(viewModel.topClients) { entry in
                            Button {
                                app.navi.push(.client(.detail(id: entry.client.id)))
                            } label: {
                                ReportsClientRow(name: entry.client.name,
                                                 amount: entry.total.currencyText(code: viewModel.currencyCode))
                            }
                        }
                    } header: {
                        ReportsSectionHeader(title: R.stringLocalizable.reports_top_clients())
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .clientItemSectionSpacing()
        }
        .groupedScreenBackground()
        .trackScreen(.reportsOverview)
    }

    @ViewBuilder
    private var statusRows: some View {
        let paid = viewModel.paid
        let unpaid = viewModel.unpaid
        let overdue = viewModel.overdue

        ReportsStatusRow(
            title: R.stringLocalizable.reports_paid(),
            subtitle: viewModel.invoiceCountText(paid.count),
            amount: paid.amount.currencyText(code: viewModel.currencyCode)
        )
        Button {
            app.navi.push(.reports(.unpaid))
        } label: {
            ReportsStatusRow(
                title: R.stringLocalizable.reports_unpaid(),
                subtitle: viewModel.invoiceCountText(unpaid.count),
                amount: unpaid.amount.currencyText(code: viewModel.currencyCode)
            )
        }
        Button {
            app.navi.push(.reports(.unpaid))
        } label: {
            ReportsStatusRow(
                title: R.stringLocalizable.reports_overdue(),
                titleColor: Color(.systemRed),
                subtitle: viewModel.invoiceCountText(overdue.count),
                amount: overdue.amount.currencyText(code: viewModel.currencyCode)
            )
        }
    }
}

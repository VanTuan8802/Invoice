//
//  ReportsUnpaidScreen.swift
//  Invoice
//
//  Reports/Unpaid: the period's unpaid and overdue invoices (same period as the
//  Overview), each opening the invoice editor. "Send Reminders to All" shares a
//  reminder message for every invoice through the system share sheet.
//

import SwiftUI
import Factory

struct ReportsUnpaidScreen: View {
    @StateObject private var viewModel = ReportsViewModel()
    /// Observed so the list refreshes when invoices change.
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.reports_unpaid_title(), showBack: true, backAction: { app.navi.pop() })

            let invoices = viewModel.outstandingInvoices
            if invoices.isEmpty {
                EmptyStateView(
                    image: R.image.illus_success,
                    title: viewModel.invoiceCountText(0),
                    message: R.stringLocalizable.reports_unpaid_empty()
                )
            } else {
                List {
                    Section {
                        ForEach(invoices) { invoice in
                            Button {
                                app.navi.push(.document(.editor(.invoice, id: invoice.id)))
                            } label: {
                                ReportsInvoiceRow(
                                    clientName: invoice.client?.name ?? R.stringLocalizable.client_no_client(),
                                    subtitle: viewModel.dueText(for: invoice),
                                    amount: invoice.balance.currencyText(code: viewModel.currencyCode),
                                    isOverdue: viewModel.isOverdue(invoice)
                                )
                            }
                        }
                    } header: {
                        ReportsSectionHeader(title: summary)
                    }

                    Section {
                        ShareLink(item: viewModel.reminderMessage) {
                            Text(R.stringLocalizable.reports_send_reminders())
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .reportsProminentButton()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .clientItemSectionSpacing()
            }
        }
        .groupedScreenBackground()
        .trackScreen(.reportsUnpaid)
    }

    /// "6 invoices · $3,160.00"
    private var summary: String {
        let total = viewModel.outstandingSummary
        return R.stringLocalizable.reports_summary(
            viewModel.invoiceCountText(total.count),
            total.amount.currencyText(code: viewModel.currencyCode)
        )
    }
}

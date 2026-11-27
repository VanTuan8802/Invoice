//
//  DocumentEditorViewModel.swift
//  Invoice
//
//  Actions of the Edit / Preview / History editor that change the open document
//  (`DocumentEditor.document`) or the store: autosave, mark paid, duplicate,
//  delete, make invoice, share / print and the history log.
//

import SwiftUI
import Factory

/// Payment methods offered by Invoice/Mark As Paid.
enum MarkPaidMethod: String, CaseIterable, Identifiable {
    case bankTransfer
    case cash
    case check
    case credit
    case debit
    case mobileApp
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bankTransfer: return R.stringLocalizable.doc_method_bank_transfer()
        case .cash:         return R.stringLocalizable.doc_method_cash()
        case .check:        return R.stringLocalizable.doc_method_check()
        case .credit:       return R.stringLocalizable.doc_method_credit()
        case .debit:        return R.stringLocalizable.doc_method_debit()
        case .mobileApp:    return R.stringLocalizable.doc_method_mobile()
        case .other:        return R.stringLocalizable.doc_method_other()
        }
    }

    /// Closest `PaymentMethod` in the model (it has no debit / mobile app case).
    var paymentMethod: PaymentMethod {
        switch self {
        case .bankTransfer: return .bankTransfer
        case .cash:         return .cash
        case .check:        return .check
        case .credit:       return .creditCard
        case .mobileApp:    return .paypal
        case .debit, .other: return .other
        }
    }
}

@MainActor
final class DocumentEditorViewModel: ObservableObject {
    @Injected(\.dataStore) private var store
    @Injected(\.documentEditor) private var editor
    @Injected(\.documentHistory) private var history

    /// Deposit presets offered by the "Amount:" row (percent of the total; 0 = none).
    let depositPresets: [Decimal] = [0, 10, 20, 25, 50]

    private var document: Document {
        get { editor.document }
        set { editor.document = newValue }
    }

    // MARK: Validation (red labels in Invoice/Edit/Scroll 1)

    var isBusinessMissing: Bool { store.business.name.isEmpty }
    var isClientMissing: Bool { document.client == nil }
    var isItemsMissing: Bool { document.items.isEmpty }
    var isReadyToSend: Bool { !isBusinessMissing && !isClientMissing && !isItemsMissing }

    // MARK: Saving

    /// Writes the document back once it is worth keeping (already stored, or has a
    /// client / an item), so an untouched "new" document never lands in the list.
    func autosave() {
        let doc = document
        guard store.document(id: doc.id) != nil || doc.client != nil || !doc.items.isEmpty else { return }
        editor.save()
    }

    // MARK: Status

    func markPaid(with method: MarkPaidMethod) {
        var doc = document
        let now = Date()
        if doc.balance > 0 {
            doc.payments.append(Payment(amount: doc.balance, method: method.paymentMethod, date: now))
        }
        doc.status = .paid
        doc.paidDate = now
        document = doc
        editor.save()
    }

    func markUnpaid() {
        document.status = .unpaid
        document.paidDate = nil
        editor.save()
    }

    func setDeposit(percent: Decimal) {
        document.deposit = Deposit(isPercentage: true, value: percent)
    }

    func depositText(code: String) -> String {
        let deposit = document.deposit
        guard deposit.value > 0 else { return R.stringLocalizable.doc_no_deposit() }
        return deposit.isPercentage ? deposit.value.percentText : deposit.value.currencyText(code: code)
    }

    // MARK: History

    func record(_ event: DocumentHistoryEvent) {
        history.record(event, for: document.id)
    }

    // MARK: Copies

    /// Duplicates the open document as a new unpaid one and opens the copy.
    func duplicate() {
        var copy = document
        copy.id = UUID()
        copy.number = store.nextNumber(for: copy.kind)
        copy.issueDate = Date()
        copy.status = .unpaid
        copy.paidDate = nil
        copy.payments = []
        store.upsert(copy)
        editor.begin(kind: copy.kind, id: copy.id)
    }

    /// Estimate → new invoice with the same client, items and adjustments. Returns its id.
    func makeInvoice() -> UUID {
        let estimate = document
        var invoice = Document(kind: .invoice, number: store.nextNumber(for: .invoice))
        invoice.client = estimate.client
        invoice.items = estimate.items
        invoice.discount = estimate.discount
        invoice.tax = estimate.tax
        invoice.photos = estimate.photos
        invoice.note = estimate.note
        invoice.templateID = estimate.templateID
        store.upsert(invoice)
        return invoice.id
    }

    func delete() {
        store.delete(document)
    }

    // MARK: Sharing

    /// One-line summary shared as text: "Invoice IV123 · $345.34".
    func shareSummary() -> String {
        R.stringLocalizable.doc_share_summary(
            document.kind.title,
            document.number,
            document.total.currencyText(code: store.currencyCode)
        )
    }

    /// Renders the preview and opens the system print panel.
    func printDocument() {
        let content = DocumentPreviewView(document: document, business: store.business, currencyCode: store.currencyCode)
            .frame(width: 393)
            .background(Color(R.color.colorFFFFFF))
        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.uiImage else { return }
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.jobName = document.number
        controller.printInfo = info
        controller.printingItem = image
        controller.present(animated: true)
    }
}

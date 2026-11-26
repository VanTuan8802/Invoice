//
//  Models.swift
//  Invoice
//
//  Shared, UI-facing data shapes for invoices, estimates, clients and items.
//  In-memory only for now (no persistence) — screens read/write them through
//  `DataStore` and `DocumentEditor`.
//

import Foundation

// MARK: - Client

struct Client: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var email: String = ""
    var mobile: String = ""
    var phone: String = ""
    var fax: String = ""
    /// Up to three free-form address lines ("Address 1" rows).
    var addressLines: [String] = ["", "", ""]

    var address: String {
        addressLines.filter { !$0.isEmpty }.joined(separator: ", ")
    }
}

// MARK: - Catalog item ("My Items")

struct CatalogItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var price: Decimal = 0
    var quantity: Decimal = 1
    var discountPercent: Decimal = 0
    var isTaxable: Bool = false
    /// "Others" free text.
    var note: String = ""
}

// MARK: - Document (invoice / estimate)

enum DocumentKind: String, Hashable, CaseIterable {
    case invoice
    case estimate
}

enum DocumentStatus: String, Hashable, CaseIterable {
    case draft
    case unpaid
    case paid
    case overdue
}

/// A row on an invoice/estimate.
struct LineItem: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var detail: String = ""
    var price: Decimal = 0
    var quantity: Decimal = 1
    var discountPercent: Decimal = 0
    var isTaxable: Bool = true

    var gross: Decimal { price * quantity }
    var discountAmount: Decimal { gross * discountPercent / 100 }
    var amount: Decimal { gross - discountAmount }
}

enum AdjustmentMode: String, Hashable, CaseIterable {
    /// "None"
    case none
    /// "On The Total"
    case onTotal
    /// "Per Item"
    case perItem
}

struct DiscountSetting: Hashable {
    var mode: AdjustmentMode = .none
    /// `true` = percentage of the subtotal, `false` = fixed amount.
    var isPercentage: Bool = true
    var value: Decimal = 0
}

struct TaxSetting: Hashable {
    var mode: AdjustmentMode = .none
    var label: String = ""
    var ratePercent: Decimal = 0
    /// "Deducted" (tax withheld from the total) vs added on top.
    var isDeducted: Bool = false
}

enum PaymentMethod: String, Hashable, CaseIterable {
    case cash
    case check
    case bankTransfer
    case creditCard
    case paypal
    case other
}

struct Payment: Identifiable, Hashable {
    var id = UUID()
    var amount: Decimal
    var method: PaymentMethod?
    var date: Date = Date()
}

/// "Payment info" shown on the invoice footer.
struct PaymentInstructions: Hashable {
    var paypalEmail: String = ""
    var checkPayableTo: String = ""
    var bankDetails: String = ""
    var other: String = ""
}

enum PaymentTerms: String, Hashable, CaseIterable {
    case dueOnReceipt
    case net7
    case net15
    case net30
    case net45
    case net60
    case custom
}

enum RepeatInterval: String, Hashable, CaseIterable {
    case never
    case weekly
    case everyTwoWeeks
    case monthly
    case quarterly
    case yearly
}

struct Deposit: Hashable {
    var isPercentage: Bool = true
    /// 0 means "No Deposit".
    var value: Decimal = 0
}

struct DocumentPhoto: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var detail: String = ""
    var imageData: Data?
}

struct Document: Identifiable, Hashable {
    var id = UUID()
    var kind: DocumentKind
    var number: String
    var issueDate: Date = Date()
    var dueDate: Date = Date()
    var terms: PaymentTerms = .dueOnReceipt
    var poNumber: String = ""
    var repeatInterval: RepeatInterval = .never
    var client: Client?
    var items: [LineItem] = []
    var discount = DiscountSetting()
    var tax = TaxSetting()
    var payments: [Payment] = []
    var deposit = Deposit()
    var paymentInstructions = PaymentInstructions()
    var photos: [DocumentPhoto] = []
    var signatureImage: Data?
    var signedDate: Date?
    var note: String = ""
    var templateID: Int = 0
    var status: DocumentStatus = .unpaid
    var paidDate: Date?

    // MARK: Totals

    var subtotal: Decimal { items.reduce(0) { $0 + $1.amount } }

    var discountTotal: Decimal {
        switch discount.mode {
        case .none:    return 0
        case .perItem: return items.reduce(0) { $0 + $1.discountAmount }
        case .onTotal: return discount.isPercentage ? subtotal * discount.value / 100 : discount.value
        }
    }

    var taxTotal: Decimal {
        let base: Decimal
        switch tax.mode {
        case .none:    return 0
        case .onTotal: base = subtotal - discountTotal
        case .perItem: base = items.filter(\.isTaxable).reduce(0) { $0 + $1.amount }
        }
        let value = base * tax.ratePercent / 100
        return tax.isDeducted ? -value : value
    }

    var total: Decimal { subtotal - discountTotal + taxTotal }
    var paidTotal: Decimal { payments.reduce(0) { $0 + $1.amount } }
    var balance: Decimal { total - paidTotal }

    var isOverdue: Bool { status != .paid && dueDate < Calendar.current.startOfDay(for: Date()) }
}

// MARK: - Business

struct BusinessProfile: Hashable {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    /// Country code shown in the phone field ("VN", "+84").
    var phoneRegion: String = "VN"
    var address: String = ""
    var website: String = ""
    var logoData: Data?
}

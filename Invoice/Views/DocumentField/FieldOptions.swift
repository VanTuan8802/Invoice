//
//  FieldOptions.swift
//  Invoice
//
//  Choices offered by the field screens' option sheets, their localized titles,
//  and how they map onto the `Document` model.
//

import Foundation

// MARK: - Terms (Invoice/Info/Terms Options)

/// "None", "Custom Date", "Due on receipt", "Next Day", "2 Days" … "8 Days".
enum FieldTermsOption: Hashable {
    case none
    case customDate
    case dueOnReceipt
    /// Due N days after the issue date (1 = "Next Day").
    case days(Int)

    static let sheetOptions: [FieldTermsOption] = [.none, .customDate, .dueOnReceipt] + (1...8).map { .days($0) }

    var title: String {
        switch self {
        case .none:            return R.stringLocalizable.common_none()
        case .customDate:      return R.stringLocalizable.field_terms_custom()
        case .dueOnReceipt:    return R.stringLocalizable.field_terms_due_on_receipt()
        case .days(1):         return R.stringLocalizable.field_terms_next_day()
        case .days(let count): return R.stringLocalizable.field_terms_days(count)
        }
    }

    /// The option describing a document's current terms. `isNone` is kept locally
    /// (`FieldDocumentExtras.termsNone`) since `PaymentTerms` has no "none" case.
    static func current(for document: Document, isNone: Bool) -> FieldTermsOption {
        if isNone { return .none }
        if let days = document.terms.fieldFixedDays {
            return days == 0 ? .dueOnReceipt : .days(days)
        }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day],
                                           from: calendar.startOfDay(for: document.issueDate),
                                           to: calendar.startOfDay(for: document.dueDate)).day ?? 0
        return (1...8).contains(days) ? .days(days) : .customDate
    }
}

extension PaymentTerms {
    /// Days between issue and due date for the fixed terms; `nil` for `.custom`.
    var fieldFixedDays: Int? {
        switch self {
        case .dueOnReceipt: return 0
        case .net7:         return 7
        case .net15:        return 15
        case .net30:        return 30
        case .net45:        return 45
        case .net60:        return 60
        case .custom:       return nil
        }
    }
}

// MARK: - Repeat (Invoice/Recurring/Repeat Options)

extension RepeatInterval {
    /// Options in the design's order ("Never" last, so recurring can be turned off).
    static let fieldSheetOptions: [RepeatInterval] = [.weekly, .everyTwoWeeks, .monthly, .quarterly, .yearly, .never]

    var fieldTitle: String {
        switch self {
        case .never:         return R.stringLocalizable.field_repeat_never()
        case .weekly:        return R.stringLocalizable.field_repeat_weekly()
        case .everyTwoWeeks: return R.stringLocalizable.field_repeat_every_two_weeks()
        case .monthly:       return R.stringLocalizable.field_repeat_monthly()
        case .quarterly:     return R.stringLocalizable.field_repeat_quarterly()
        case .yearly:        return R.stringLocalizable.field_repeat_yearly()
        }
    }

    /// Footer sentence under the Recurring screen's delivery section.
    func fieldFooter(sendsAutomatically: Bool) -> String {
        let phrase: String
        switch self {
        case .never:         return R.stringLocalizable.field_repeat_footer()
        case .weekly:        phrase = R.stringLocalizable.field_recurring_every_week()
        case .everyTwoWeeks: phrase = R.stringLocalizable.field_recurring_every_two_weeks()
        case .monthly:       phrase = R.stringLocalizable.field_recurring_every_month()
        case .quarterly:     phrase = R.stringLocalizable.field_recurring_every_quarter()
        case .yearly:        phrase = R.stringLocalizable.field_recurring_every_year()
        }
        return sendsAutomatically
            ? R.stringLocalizable.field_recurring_footer_auto(phrase)
            : R.stringLocalizable.field_recurring_footer_manual(phrase)
    }
}

// MARK: - Discount (Invoice/Discount/Options)

/// "Percentage", "Flat Amount", "Not Discount".
enum FieldDiscountOption: CaseIterable {
    case percentage
    case flatAmount
    case none

    var title: String {
        switch self {
        case .percentage: return R.stringLocalizable.field_discount_percentage()
        case .flatAmount: return R.stringLocalizable.field_discount_flat()
        case .none:       return R.stringLocalizable.field_discount_none()
        }
    }

    func apply(to discount: inout DiscountSetting) {
        switch self {
        case .percentage:
            discount.mode = .onTotal
            discount.isPercentage = true
        case .flatAmount:
            discount.mode = .onTotal
            discount.isPercentage = false
        case .none:
            discount.mode = .none
            discount.value = 0
        }
    }
}

extension DiscountSetting {
    var fieldTitle: String {
        switch mode {
        case .none:    return FieldDiscountOption.none.title
        case .perItem: return R.stringLocalizable.field_mode_per_item()
        case .onTotal: return (isPercentage ? FieldDiscountOption.percentage : .flatAmount).title
        }
    }
}

// MARK: - Tax (Invoice/Tax/Options)

/// "None", "On The Total", "Per Item", plus "Deducted" (tax withheld from the total).
enum FieldTaxOption: CaseIterable {
    case none
    case onTotal
    case perItem
    case deducted

    var title: String {
        switch self {
        case .none:     return R.stringLocalizable.common_none()
        case .onTotal:  return R.stringLocalizable.field_mode_on_total()
        case .perItem:  return R.stringLocalizable.field_mode_per_item()
        case .deducted: return R.stringLocalizable.field_tax_deducted()
        }
    }

    init(_ tax: TaxSetting) {
        switch tax.mode {
        case .none:    self = .none
        case .perItem: self = .perItem
        case .onTotal: self = tax.isDeducted ? .deducted : .onTotal
        }
    }

    func apply(to tax: inout TaxSetting) {
        switch self {
        case .none:     tax.mode = .none;    tax.isDeducted = false
        case .onTotal:  tax.mode = .onTotal; tax.isDeducted = false
        case .perItem:  tax.mode = .perItem; tax.isDeducted = false
        case .deducted: tax.mode = .onTotal; tax.isDeducted = true
        }
    }
}

// MARK: - Payment method (Invoice/Payment/Method Options)

/// The design's seven methods. `PaymentMethod` has no debit / mobile-app cases:
/// "Debit" is stored as `.creditCard` and "Mobile payment app" as `.paypal`.
enum FieldPaymentMethodOption: CaseIterable {
    case bankTransfer
    case cash
    case check
    case credit
    case debit
    case mobileApp
    case other

    var title: String {
        switch self {
        case .bankTransfer: return R.stringLocalizable.field_method_bank_transfer()
        case .cash:         return R.stringLocalizable.field_method_cash()
        case .check:        return R.stringLocalizable.field_method_check()
        case .credit:       return R.stringLocalizable.field_method_credit()
        case .debit:        return R.stringLocalizable.field_method_debit()
        case .mobileApp:    return R.stringLocalizable.field_method_mobile()
        case .other:        return R.stringLocalizable.field_method_other()
        }
    }

    var method: PaymentMethod {
        switch self {
        case .bankTransfer:   return .bankTransfer
        case .cash:           return .cash
        case .check:          return .check
        case .credit, .debit: return .creditCard
        case .mobileApp:      return .paypal
        case .other:          return .other
        }
    }

    init(_ method: PaymentMethod) {
        switch method {
        case .cash:         self = .cash
        case .check:        self = .check
        case .bankTransfer: self = .bankTransfer
        case .creditCard:   self = .credit
        case .paypal:       self = .mobileApp
        case .other:        self = .other
        }
    }
}

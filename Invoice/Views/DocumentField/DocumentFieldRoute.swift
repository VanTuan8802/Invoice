//
//  DocumentFieldRoute.swift
//  Invoice
//
//  Screens that edit one part of the open document (`DocumentEditor.document`).
//  `Destination.documentField`. Owned by the Document Field feature.
//

import SwiftUI

enum DocumentFieldRoute: Hashable {
    /// Invoice/Info, Estimate/Info (+ Terms Options)
    case info
    /// Invoice/Template. `isDefault == true` when opened from Settings (default template).
    case template(isDefault: Bool)
    /// Invoice/Email (+ Contacts, Sent)
    case email
    /// Invoice/Discount (+ Options)
    case discount
    /// Invoice/Tax (+ Options)
    case tax
    /// Invoice/Payment/List
    case payments
    /// Invoice/Payment (+ Method Options). `id == nil` adds a payment.
    case payment(id: UUID?)
    /// Invoice/Payment Info
    case paymentInfo
    /// Invoice/Note
    case note
    /// Invoice/Recurring (+ Repeat Options)
    case recurring

    var identifier: String {
        switch self {
        case .info:                  return "field.info"
        case .template(let isDefault): return "field.template.\(isDefault)"
        case .email:                 return "field.email"
        case .discount:              return "field.discount"
        case .tax:                   return "field.tax"
        case .payments:              return "field.payments"
        case .payment(let id):       return "field.payment.\(id?.uuidString ?? "new")"
        case .paymentInfo:           return "field.paymentInfo"
        case .note:                  return "field.note"
        case .recurring:             return "field.recurring"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .info:                    FieldInfoScreen()
        case .template(let isDefault): FieldTemplateScreen(isDefault: isDefault)
        case .email:                   FieldEmailScreen()
        case .discount:                FieldDiscountScreen()
        case .tax:                     FieldTaxScreen()
        case .payments:                FieldPaymentsScreen()
        case .payment(let id):         FieldPaymentScreen(paymentID: id)
        case .paymentInfo:             FieldPaymentInfoScreen()
        case .note:                    FieldNoteScreen()
        case .recurring:               FieldRecurringScreen()
        }
    }

    #if DEBUG
    /// `-uiPreview <key>` → route (see `App/UIPreview.swift`).
    static var debugPreviews: [String: DocumentFieldRoute] {
        [
            "field.info": .info,
            "field.template": .template(isDefault: false),
            "field.template.default": .template(isDefault: true),
            "field.email": .email,
            "field.discount": .discount,
            "field.tax": .tax,
            "field.payments": .payments,
            "field.payment": .payment(id: nil),
            "field.paymentInfo": .paymentInfo,
            "field.note": .note,
            "field.recurring": .recurring
        ]
    }
    #endif
}

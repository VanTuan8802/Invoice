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
        case .info, .template, .email, .discount, .tax, .payments, .payment, .paymentInfo, .note, .recurring:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: DocumentFieldRoute] {
        ["field.info": .info]
    }
    #endif
}

//
//  DocumentRoute.swift
//  Invoice
//
//  Invoice & estimate screens (`Destination.document`). Owned by the Document feature.
//

import SwiftUI

enum DocumentRoute: Hashable {
    /// Invoice/List, Estimate/List (+ Empty)
    case list(DocumentKind)
    /// Invoice/Search (+ Results)
    case search(DocumentKind)
    /// Invoice/Filter
    case filter(DocumentKind)
    /// Edit / Preview / History segmented screen. `id == nil` creates a new document.
    case editor(DocumentKind, id: UUID?)
    /// Invoice/Share
    case share
    /// Invoice/Signature (landscape pad)
    case signature
    /// Invoice/Photo (+ Options)
    case photo
    /// Invoice/Mark As Paid
    case markAsPaid

    var identifier: String {
        switch self {
        case .list(let kind):            return "document.list.\(kind.rawValue)"
        case .search(let kind):          return "document.search.\(kind.rawValue)"
        case .filter(let kind):          return "document.filter.\(kind.rawValue)"
        case .editor(let kind, let id):  return "document.editor.\(kind.rawValue).\(id?.uuidString ?? "new")"
        case .share:                     return "document.share"
        case .signature:                 return "document.signature"
        case .photo:                     return "document.photo"
        case .markAsPaid:                return "document.markAsPaid"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .list, .search, .filter, .editor, .share, .signature, .photo, .markAsPaid:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    /// `-uiPreview <key>` → route (see `App/UIPreview.swift`).
    static var debugPreviews: [String: DocumentRoute] {
        [
            "document.list.invoice": .list(.invoice),
            "document.list.estimate": .list(.estimate)
        ]
    }
    #endif
}

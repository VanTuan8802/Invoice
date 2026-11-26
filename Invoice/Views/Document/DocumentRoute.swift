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
    /// Invoice/Share — the editor of the open document with the send options shown.
    case share
    /// Invoice/Signature (landscape pad)
    case signature
    /// Invoice/Photo (+ Options) — adds a new photo to the open document.
    case photo
    /// Invoice/Mark As Paid — the editor of the open document with the payment methods shown.
    case markAsPaid
    /// Invoice/Photo for a photo already on the open document.
    case photoDetail(id: UUID)
    #if DEBUG
    /// Debug previews only: the editor on the first stored document of `kind`, opened on `tab`.
    case sample(DocumentKind, tab: DocumentEditorTab)
    #endif

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
        case .photoDetail(let id):       return "document.photo.\(id.uuidString)"
        #if DEBUG
        case .sample(let kind, let tab): return "document.sample.\(kind.rawValue).\(tab.rawValue)"
        #endif
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .list(let kind):
            DocumentListScreen(kind: kind)
        case .search(let kind):
            DocumentSearchScreen(kind: kind)
        case .filter(let kind):
            DocumentFilterScreen(kind: kind)
        case .editor(let kind, let id):
            DocumentEditorScreen(source: .document(kind, id: id))
        case .share:
            DocumentEditorScreen(source: .current, startAction: .share)
        case .signature:
            SignatureScreen()
        case .photo:
            PhotoScreen(photoID: nil)
        case .markAsPaid:
            DocumentEditorScreen(source: .current, startAction: .markPaid)
        case .photoDetail(let id):
            PhotoScreen(photoID: id)
        #if DEBUG
        case .sample(let kind, let tab):
            DocumentEditorScreen(source: .firstStored(kind), initialTab: tab)
        #endif
        }
    }

    #if DEBUG
    /// `-uiPreview <key>` → route (see `App/UIPreview.swift`).
    static var debugPreviews: [String: DocumentRoute] {
        [
            "document.list.invoice": .list(.invoice),
            "document.list.estimate": .list(.estimate),
            "document.search.invoice": .search(.invoice),
            "document.search.estimate": .search(.estimate),
            "document.filter.invoice": .filter(.invoice),
            "document.editor.invoice": .sample(.invoice, tab: .edit),
            "document.editor.invoice.new": .editor(.invoice, id: nil),
            "document.preview.invoice": .sample(.invoice, tab: .preview),
            "document.history.invoice": .sample(.invoice, tab: .history),
            "document.editor.estimate": .sample(.estimate, tab: .edit),
            "document.editor.estimate.new": .editor(.estimate, id: nil),
            "document.preview.estimate": .sample(.estimate, tab: .preview),
            "document.history.estimate": .sample(.estimate, tab: .history),
            "document.share": .share,
            "document.markAsPaid": .markAsPaid,
            "document.signature": .signature,
            "document.photo": .photo
        ]
    }
    #endif
}

//
//  ClientRoute.swift
//  Invoice
//
//  Client screens (`Destination.client`). Owned by the Client feature.
//

import SwiftUI

enum ClientRoute: Hashable {
    /// Client/List (+ Empty). `isPicker == true` when choosing a client for a document.
    case list(isPicker: Bool)
    /// Client/Info, Client/Info 2
    case detail(id: UUID)
    /// Client/Edit (+ Discard Dialog). `id == nil` creates a client.
    case edit(id: UUID?)

    var identifier: String {
        switch self {
        case .list(let isPicker): return "client.list.\(isPicker)"
        case .detail(let id):     return "client.detail.\(id)"
        case .edit(let id):       return "client.edit.\(id?.uuidString ?? "new")"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .list(let isPicker):
            ClientListScreen(isPicker: isPicker)
        case .detail(let id):
            ClientDetailScreen(clientID: id)
        case .edit(let id):
            ClientEditScreen(clientID: id)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: ClientRoute] {
        [
            "client.list": .list(isPicker: false),
            "client.picker": .list(isPicker: true),
            "client.detail": .detail(id: SampleData.clients[0].id),
            "client.edit": .edit(id: nil)
        ]
    }
    #endif
}

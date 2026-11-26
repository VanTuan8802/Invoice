//
//  ClientDetailScreen.swift
//  Invoice
//
//  Client/Info (and the identical Client/Info 2): an existing client's details,
//  editable in place; "Done" keeps the changes.
//

import SwiftUI

struct ClientDetailScreen: View {
    let clientID: UUID

    var body: some View {
        ClientFormScreen(
            clientID: clientID,
            confirmTitle: R.stringLocalizable.common_done(),
            screen: .clientDetail
        )
    }
}

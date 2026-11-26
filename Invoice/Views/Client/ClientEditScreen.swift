//
//  ClientEditScreen.swift
//  Invoice
//
//  Client/Edit (+ Discard Dialog): creates a client (`id == nil`) or updates
//  one; "Save" writes it to the store.
//

import SwiftUI

struct ClientEditScreen: View {
    let clientID: UUID?

    var body: some View {
        ClientFormScreen(
            clientID: clientID,
            confirmTitle: R.stringLocalizable.save(),
            screen: .clientEdit
        )
    }
}

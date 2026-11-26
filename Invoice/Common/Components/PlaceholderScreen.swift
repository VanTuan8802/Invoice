//
//  PlaceholderScreen.swift
//  Invoice
//
//  Scaffolding only: stands in for a route whose real screen is not built yet.
//  Feature routes replace it with their screen; nothing should ship using it.
//

import SwiftUI
import Factory

struct PlaceholderScreen: View {
    /// Route identifier, shown so it is obvious which screen is missing.
    let routeID: String
    @Injected(\.app) private var app

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(routeID, showBack: true, backAction: { app.navi.pop() })
            Spacer()
            Image(systemName: "hammer")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .groupedScreenBackground()
    }
}

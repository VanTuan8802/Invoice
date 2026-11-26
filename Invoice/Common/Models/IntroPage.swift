//
//  IntroPage.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

struct IntroPage: Identifiable {
    let id = UUID()
    let systemImage: String
    /// Resolved on every call (not stored) so the text follows the in-app
    /// language when it changes at runtime.
    let title: () -> String
    let message: () -> String
    let tint: Color

    /// The three slides shown in order.
    static let all: [IntroPage] = [
        IntroPage(
            systemImage: "square.grid.2x2.fill",
            title: { R.stringLocalizable.intro_title_1() },
            message: { R.stringLocalizable.intro_message_1() },
            tint: .blue
        ),
        IntroPage(
            systemImage: "bolt.fill",
            title: { R.stringLocalizable.intro_title_2() },
            message: { R.stringLocalizable.intro_message_2() },
            tint: .orange
        ),
        IntroPage(
            systemImage: "checkmark.seal.fill",
            title: { R.stringLocalizable.intro_title_3() },
            message: { R.stringLocalizable.intro_message_3() },
            tint: .green
        )
    ]
}

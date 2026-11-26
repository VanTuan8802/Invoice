//
//  View+CardSurface.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

extension View {
    /// Pads the content and places it on the design's white rounded card
    /// (list rows: radius 28, padding 16).
    func cardSurface(cornerRadius: CGFloat = 28, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(R.color.colorFFFFFF))
            )
    }

    /// Full-screen grouped background (#F2F2F7, Backgrounds – Grouped/Primary).
    func groupedScreenBackground() -> some View {
        background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

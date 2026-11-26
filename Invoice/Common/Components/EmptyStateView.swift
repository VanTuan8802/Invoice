//
//  EmptyStateView.swift
//  Invoice
//
//  Centered illustration + title + message for empty lists
//  (e.g. "You don't have any invoice.").
//

import SwiftUI

struct EmptyStateView: View {
    let image: RswiftResources.ImageResource
    /// Already-localized texts.
    let title: String
    let message: String
    var imageSize: CGFloat = 160

    var body: some View {
        VStack(spacing: 12) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .padding(.bottom, 16)
            Text(title)
                .font(.title3)
                .foregroundStyle(Color(R.color.color111118))
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color(R.color.color8E8E93))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

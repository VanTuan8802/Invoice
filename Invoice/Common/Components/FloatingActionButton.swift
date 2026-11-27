//
//  FloatingActionButton.swift
//  Invoice
//
//  52pt ink circle anchored bottom-trailing (e.g. "+" on list screens).
//

import SwiftUI

struct FloatingActionButton: View {
    /// Icon drawn in the middle. Defaults to the design's plus glyph.
    var icon: RswiftResources.ImageResource = R.image.ic_common_plus
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(icon)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color(R.color.color111118)))
                .buttonElevation()
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

extension View {
    /// Pins a `FloatingActionButton` 16pt from the trailing edge and 66pt above the
    /// bottom safe area (100pt from the screen edge, as in the design).
    func floatingActionButton(
        icon: RswiftResources.ImageResource = R.image.ic_common_plus,
        action: @escaping () -> Void
    ) -> some View {
        overlay(alignment: .bottomTrailing) {
            FloatingActionButton(icon: icon, action: action)
                .padding(.trailing, 16)
                .padding(.bottom, 66)
        }
    }
}

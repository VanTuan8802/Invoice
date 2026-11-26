//
//  SearchEntryField.swift
//  Invoice
//
//  44pt capsule search field (Fills/Tertiary background, 18pt search glyph).
//  Pass `text` for an editable field, or `onTap` for a tap-to-open entry.
//

import SwiftUI

struct SearchEntryField: View {
    /// Already-localized placeholder, e.g. "Search invoices".
    let placeholder: String
    var text: Binding<String>?
    var onTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Image(R.image.ic_common_search)
            if let text {
                TextField(placeholder, text: text)
                    .font(.body)
                    .foregroundStyle(Color(R.color.color111118))
                    .submitLabel(.search)
            } else {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Capsule().fill(Color(.tertiarySystemFill)))
        .contentShape(Capsule())
        .onTapGesture { onTap?() }
    }
}

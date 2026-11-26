//
//  PrimaryButton.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

struct PrimaryButton: View {
    /// Already-localized text, e.g. `R.stringLocalizable.continue()`.
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
        }
    }
}

#if DEBUG
#Preview {
    PrimaryButton(R.stringLocalizable.continue()) {}
        .padding()
}
#endif

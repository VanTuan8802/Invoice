//
//  LabeledInputField.swift
//  Invoice
//
//  Onboarding / business-details style input: grey subheadline label (with a red
//  asterisk when required) above a white 48pt capsule field.
//

import SwiftUI

struct LabeledInputField<Trailing: View>: View {
    /// Already-localized label.
    let label: String
    var isRequired: Bool = false
    var placeholder: String = ""
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    @ViewBuilder var trailing: () -> Trailing

    init(
        _ label: String,
        isRequired: Bool = false,
        placeholder: String = "",
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.label = label
        self.isRequired = isRequired
        self.placeholder = placeholder
        self._text = text
        self.keyboard = keyboard
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            (Text(label).foregroundColor(Color(R.color.color6B6B78))
             + Text(isRequired ? "*" : "").foregroundColor(Color(R.color.colorFA0000)))
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

            HStack(spacing: 8) {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color(R.color.colorA5A5B0)))
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color151515))
                    .keyboardType(keyboard)
                trailing()
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(R.color.colorFFFFFF)))
        }
    }
}

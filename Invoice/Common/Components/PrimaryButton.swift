//
//  PrimaryButton.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

/// Full-width 48pt capsule button from the design ("Button" component).
/// - `.primary`: ink #111118 fill, white label, elevation shadow.
/// - `.outline`: white fill, 1pt ink border, purple #6A4DF5 label (e.g. "Skip").
/// Disabled: #DFDFDF fill, #8E8E9A label at 70%.
struct PrimaryButton: View {
    enum Style {
        case primary
        case outline
    }

    /// Already-localized text, e.g. `R.stringLocalizable.continue()`.
    let title: String
    var style: Style = .primary
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    /// 16pt label (design) that still grows with Dynamic Type.
    @ScaledMetric(relativeTo: .callout) private var fontSize: CGFloat = 16

    init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(foreground)
                .opacity(isEnabled ? 1 : 0.7)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .frame(minHeight: 48)
                .background(background)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        guard isEnabled else { return Color(R.color.color8E8E9A) }
        switch style {
        case .primary: return Color(R.color.colorFFFFFF)
        case .outline: return Color(R.color.color6A4DF5)
        }
    }

    @ViewBuilder
    private var background: some View {
        if !isEnabled {
            Capsule().fill(Color(R.color.colorDFDFDF))
        } else {
            switch style {
            case .primary:
                Capsule().fill(Color(R.color.color111118)).buttonElevation()
            case .outline:
                Capsule()
                    .fill(Color(R.color.colorFFFFFF))
                    .overlay(Capsule().strokeBorder(Color(R.color.color111118), lineWidth: 1))
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        PrimaryButton(R.stringLocalizable.get_started()) {}
        PrimaryButton(R.stringLocalizable.continue()) {}.disabled(true)
        PrimaryButton(R.stringLocalizable.skip(), style: .outline) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
#endif

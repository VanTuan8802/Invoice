//
//  OptionsSheet.swift
//  Invoice
//
//  The design's "Options" action sheets (Terms, Discount, Tax, Payment method,
//  Repeat, the editor's "…" menu, Mark As Paid, photo source): a floating card
//  of 48pt option buttons 16pt from the screen edges, a separate Cancel below
//  it and a dimmed backdrop. Built by hand because on iOS 26
//  `confirmationDialog` renders as a small popover instead.
//

import SwiftUI

extension View {
    /// Shows `actions` (plain `Button`s; `role: .destructive` turns red) in the
    /// design's bottom options sheet. Any tap on an option, the backdrop or
    /// Cancel closes it. Do not add a Cancel button yourself.
    func optionsSheet<Actions: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> Actions
    ) -> some View {
        overlay {
            OptionsSheet(isPresented: isPresented, actions: actions)
        }
    }
}

private struct OptionsSheet<Actions: View>: View {
    @Binding var isPresented: Bool
    let actions: () -> Actions

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                    .transition(.opacity)

                VStack(spacing: 8) {
                    // Long lists (Terms has 11 options) scroll instead of running off screen.
                    ViewThatFits(in: .vertical) {
                        optionList
                        ScrollView { optionList }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.regularMaterial)
                    )
                    .overlay(
                        // The design's glass rim.
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                    )
                    .simultaneousGesture(TapGesture().onEnded { isPresented = false })

                    Button(R.stringLocalizable.common_cancel()) { isPresented = false }
                        .buttonStyle(OptionsSheetButtonStyle(isCancel: true))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityAddTraits(.isModal)
            }
        }
        .animation(.easeOut(duration: 0.22), value: isPresented)
    }

    private var optionList: some View {
        VStack(spacing: 8) {
            actions()
        }
        .buttonStyle(OptionsSheetButtonStyle(isCancel: false))
        .padding(14)
    }
}

/// 48pt capsule rows: a translucent grey pill inside the card (about 24 levels
/// darker than the card, as in the design) and a darker frosted pill for Cancel.
private struct OptionsSheetButtonStyle: ButtonStyle {
    let isCancel: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(configuration.role == .destructive ? Color.red : Color(R.color.color111118))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background(background)
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }

    @ViewBuilder
    private var background: some View {
        if isCancel {
            Capsule()
                .fill(.thinMaterial)
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
        } else {
            Capsule().fill(Color.black.opacity(0.1))
        }
    }
}

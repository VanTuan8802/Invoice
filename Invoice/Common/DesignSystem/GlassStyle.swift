//
//  GlassStyle.swift
//  Invoice
//
//  Liquid Glass surfaces from the design (iOS 26+), with a plain fallback for
//  older systems (the app still deploys to iOS 16).
//

import SwiftUI

extension View {
    /// Circular glass chip used by toolbar buttons (back, more, close…).
    @ViewBuilder
    func glassCircle(interactive: Bool = true) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(interactive ? .regular.interactive() : .regular, in: .circle)
        } else {
            self
                .background(Circle().fill(Color(R.color.colorFFFFFF)))
                .shadow(color: Color(R.color.color111118).opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }

    /// Capsule glass surface for free-floating pills.
    @ViewBuilder
    func glassCapsule(interactive: Bool = true) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(interactive ? .regular.interactive() : .regular, in: .capsule)
        } else {
            self
                .background(Capsule().fill(Color(R.color.colorFFFFFF)))
                .shadow(color: Color(R.color.color111118).opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }

    /// `v3/Elevation/Button`: drop shadow #111118 @16%, y 8, blur 18, spread -4.
    func buttonElevation() -> some View {
        shadow(color: Color(R.color.color111118).opacity(0.16), radius: 9, x: 0, y: 8)
    }
}

/// Press feedback without the system's automatic disabled dimming, for buttons
/// that draw their own disabled look (otherwise the two fades stack up and the
/// label becomes unreadable).
struct PressFadeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

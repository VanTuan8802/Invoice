//
//  PremiumRoute.swift
//  Invoice
//
//  Paywall screens (`Destination.premium`), reachable from onboarding and from
//  the Settings "Upgrade To Premium" banner. Owned by the Onboarding feature.
//
//  Open from anywhere in the app with
//  `app.navi.push(.premium(.plans), type: .fullScreenCover)`; Close dismisses
//  the cover, a purchase shows `.success`, which then closes the cover too.
//  (Inside onboarding the same screens are shown by `AppPhase.premium` /
//  `.premiumSuccess` instead of the router.)
//

import SwiftUI

enum PremiumRoute: Hashable {
    /// Onboarding/Premium/Plans
    case plans
    /// Onboarding/Premium/Success
    case success

    var identifier: String {
        switch self {
        case .plans:   return "premium.plans"
        case .success: return "premium.success"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .plans:
            PremiumPlansScreen(context: .modal)
        case .success:
            PremiumSuccessScreen(context: .modal)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: PremiumRoute] {
        [
            "premium.plans": .plans,
            "premium.success": .success
        ]
    }
    #endif
}

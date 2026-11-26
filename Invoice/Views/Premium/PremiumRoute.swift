//
//  PremiumRoute.swift
//  Invoice
//
//  Paywall screens (`Destination.premium`), reachable from onboarding and from
//  the Settings "Upgrade To Premium" banner. Owned by the Onboarding feature.
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
        case .plans, .success:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: PremiumRoute] {
        ["premium.plans": .plans]
    }
    #endif
}

//
//  ReportsRoute.swift
//  Invoice
//
//  Reports screens (`Destination.reports`). Owned by the Reports feature.
//

import SwiftUI

enum ReportsRoute: Hashable {
    /// Reports/Overview
    case overview
    /// Reports/Unpaid
    case unpaid

    var identifier: String {
        switch self {
        case .overview: return "reports.overview"
        case .unpaid:   return "reports.unpaid"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .overview, .unpaid:
            PlaceholderScreen(routeID: identifier)
        }
    }

    #if DEBUG
    static var debugPreviews: [String: ReportsRoute] {
        ["reports.overview": .overview]
    }
    #endif
}

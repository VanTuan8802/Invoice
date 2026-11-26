//
//  Destination.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

/// Every pushable / presentable screen. Each feature owns its own route enum
/// (in `Views/<Feature>/<Feature>Route.swift`) with its cases, identifiers and
/// screens, so features never edit the same switch.
enum Destination: Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }

    case home
    case language
    case premium(PremiumRoute)
    case document(DocumentRoute)
    case documentField(DocumentFieldRoute)
    case client(ClientRoute)
    case item(ItemRoute)
    case reports(ReportsRoute)
    case settings(SettingsRoute)
}

extension Destination {
    var identifier: String {
        switch self {
        case .home:                       return "home"
        case .language:                   return "language"
        case .premium(let route):         return route.identifier
        case .document(let route):        return route.identifier
        case .documentField(let route):   return route.identifier
        case .client(let route):          return route.identifier
        case .item(let route):            return route.identifier
        case .reports(let route):         return route.identifier
        case .settings(let route):        return route.identifier
        }
    }
}

extension Navigation {
    @ViewBuilder
    internal func screen(for destinationWrapper: DestinationWrapper) -> some View {
        switch destinationWrapper.destination {
        case .home:                       HomeScreen()
        case .language:                   LanguageView(mode: .settings)
        case .premium(let route):         route.screen
        case .document(let route):        route.screen
        case .documentField(let route):   route.screen
        case .client(let route):          route.screen
        case .item(let route):            route.screen
        case .reports(let route):         route.screen
        case .settings(let route):        route.screen
        }
    }
}

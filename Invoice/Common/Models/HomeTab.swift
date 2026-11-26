//
//  HomeTab.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

enum HomeTab: Hashable, CaseIterable {
    case home
    case search
    case favorites
    case settings

    var title: String {
        switch self {
        case .home:      return R.stringLocalizable.home()
        case .search:    return R.stringLocalizable.search()
        case .favorites: return R.stringLocalizable.favorites()
        case .settings:  return R.stringLocalizable.settings()
        }
    }

    /// SF Symbol name for the tab bar item.
    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .search:    return "magnifyingglass"
        case .favorites: return "heart.fill"
        case .settings:  return "gearshape.fill"
        }
    }
}

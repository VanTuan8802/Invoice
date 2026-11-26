//
//  HomeViewModel.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI
import Factory

@MainActor
final class HomeViewModel: ObservableObject {
    @Injected(\.app) private var app

    /// The four quick-action tiles, in grid order.
    enum Tile: CaseIterable, Identifiable {
        case invoice
        case estimate
        case client
        case item

        var id: Self { self }

        var title: String {
            switch self {
            case .invoice:  return R.stringLocalizable.home_tile_invoice()
            case .estimate: return R.stringLocalizable.home_tile_estimate()
            case .client:   return R.stringLocalizable.home_tile_client()
            case .item:     return R.stringLocalizable.home_tile_item()
            }
        }

        var illustration: RswiftResources.ImageResource {
            switch self {
            case .invoice:  return R.image.illus_invoice
            case .estimate: return R.image.illus_estimate
            case .client:   return R.image.illus_client
            case .item:     return R.image.illus_item
            }
        }

        var background: Color {
            switch self {
            case .invoice:  return Color(R.color.colorB4A5FF) // block/lavender
            case .estimate: return Color(R.color.colorA9C8FF) // block/sky
            case .client:   return Color(R.color.colorF7A6F2) // block/pink
            case .item:     return Color(R.color.colorFFBE5C) // block/orange
            }
        }

        var destination: Destination {
            switch self {
            case .invoice:  return .document(.list(.invoice))
            case .estimate: return .document(.list(.estimate))
            case .client:   return .client(.list(isPicker: false))
            case .item:     return .item(.list(isPicker: false))
            }
        }
    }

    /// "Thursday, 06 Nov" (day before month, as in the design) in the language
    /// picked in-app; Japanese keeps its native month-day order.
    var todayText: String {
        let language = OnboardingStore().currentLanguage
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.rawValue)
        if language == .japanese {
            formatter.setLocalizedDateFormatFromTemplate("MMMdEEEE")
        } else {
            formatter.dateFormat = "EEEE, dd MMM"
        }
        return formatter.string(from: Date())
    }

    /// Show the `interHome` interstitial, then navigate. The SDK throttles by
    /// `intervalShowInter`, so rapid taps won't stack ads; if disabled, the
    /// callback fires immediately and we just navigate.
    func open(_ tile: Tile) {
        InterHomeUtil.instance.show(placement: .home) { [weak self] in
            self?.app.navi.push(tile.destination)
        }
    }

    func openReports() {
        app.navi.push(.reports(.overview))
    }

    func openSettings() {
        app.navi.push(.settings(.main))
    }
}

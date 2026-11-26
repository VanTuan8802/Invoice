//
//  SettingsViewModel.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation
import Factory
import StoreKit
import UIKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Injected(\.app) private var app

    let appName = "Invoice"

    // MARK: Navigation

    func back() {
        app.navi.pop()
    }

    func openPremium() {
        app.navi.push(.premium(.plans), type: .fullScreenCover)
    }

    func open(_ route: SettingsRoute) {
        app.navi.push(.settings(route))
    }

    /// Default invoice template (screen owned by the Document Field feature).
    func openTemplate() {
        app.navi.push(.documentField(.template(isDefault: true)))
    }

    func openLanguage() {
        app.navi.push(.language)
    }

    // MARK: About

    /// Text shared by the "Share" row.
    var shareMessage: String {
        let link = AppConstants.appLi
        return link.isEmpty ? appName : "\(appName)\n\(link)"
    }

    /// Privacy-policy destination. `nil` while not configured (tap does nothing).
    var policyURL: URL? {
        guard !AppConstants.policyLink.isEmpty else { return nil }
        return URL(string: AppConstants.policyLink)
    }

    /// Native in-app review prompt (falls back silently if the OS suppresses it).
    func rateApp() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

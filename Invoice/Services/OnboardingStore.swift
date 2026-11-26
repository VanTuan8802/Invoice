//
//  OnboardingStore.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

final class OnboardingStore {

    private let defaults: UserDefaults

    private enum Keys {
        static let didOnboard = "appflow.didCompleteOnboarding"
        // Read by `R.stringLocalizable` so the picked language drives lookups.
        static let language = Constants.Key.languageSelected
        static let templateID = "appflow.templateID"
        static let isPremium = "appflow.isPremium"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// `true` once the user has finished the onboarding flow at least once.
    var hasOnboarded: Bool {
        get { defaults.bool(forKey: Keys.didOnboard) }
        set { defaults.set(newValue, forKey: Keys.didOnboard) }
    }

    /// The persisted language, or `nil` if the user hasn't chosen yet.
    var language: AppLanguage? {
        get { AppLanguage(rawValue: defaults.string(forKey: Keys.language) ?? "") }
        set { defaults.set(newValue?.rawValue, forKey: Keys.language) }
    }

    /// Language used for text lookups (`R.stringLocalizable`): the persisted
    /// choice, or English until the user has picked one.
    var currentLanguage: AppLanguage { language ?? .english }

    /// Invoice template picked during onboarding (index into the template list,
    /// same meaning as `Document.templateID`). Defaults to the first template.
    var templateID: Int {
        get { defaults.integer(forKey: Keys.templateID) }
        set { defaults.set(newValue, forKey: Keys.templateID) }
    }

    /// Premium unlocked. Set by the (simulated) paywall purchase until StoreKit
    /// is wired in.
    var isPremium: Bool {
        get { defaults.bool(forKey: Keys.isPremium) }
        set { defaults.set(newValue, forKey: Keys.isPremium) }
    }
}

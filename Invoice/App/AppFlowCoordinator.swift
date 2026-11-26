//
//  AppFlowCoordinator.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//


import SwiftUI
import Combine

@MainActor
final class AppFlowCoordinator: ObservableObject {

    /// The phase currently shown by `ContainerView`.
    @Published private(set) var phase: AppPhase = .splash

    /// The language the user picked (or the system default the first time).
    @Published var language: AppLanguage

    /// Template chosen on the onboarding template picker.
    @Published private(set) var templateID: Int

    /// Premium unlocked (simulated purchase until StoreKit lands).
    @Published private(set) var isPremium: Bool

    private let store: OnboardingStore

    init(store: OnboardingStore = OnboardingStore()) {
        self.store = store
        self.language = store.language ?? .deviceDefault
        self.templateID = store.templateID
        self.isPremium = store.isPremium
    }

    // MARK: - Derived state

    /// `true` once the user has finished the onboarding flow at least once.
    var hasOnboarded: Bool { store.hasOnboarded }

    // MARK: - Transitions

    /// Called when the splash screen finishes. Returning users skip onboarding.
    func splashDidFinish() {
        phase = hasOnboarded ? .home : .language
    }

    /// Called from the onboarding language picker's "Save" button: persists
    /// the choice and advances the flow to the intro carousel.
    func didSelectLanguage(_ language: AppLanguage) {
        self.language = language
        store.language = language
        phase = .intro
    }

    /// Called from the Settings language picker: persists the choice without
    /// touching the launch phase (the user is already in `.home`).
    func updateLanguage(_ language: AppLanguage) {
        self.language = language
        store.language = language
    }

    /// Intro carousel finished ("Start") → Welcome.
    func introDidFinish() {
        phase = .welcome
    }

    /// Welcome "Get Started" → business details.
    func welcomeDidFinish() {
        phase = .businessDetails
    }

    /// `true` once the business step was saved in this onboarding run, so going
    /// back to it shows what the user typed (instead of starting blank).
    private(set) var didSaveBusinessDetails = false

    /// Business details saved (`saved == true`) or skipped → logo upload.
    func businessDetailsDidFinish(saved: Bool) {
        if saved { didSaveBusinessDetails = true }
        phase = .businessLogo
    }

    /// Logo saved or skipped → template picker.
    func businessLogoDidFinish() {
        phase = .template
    }

    /// Template confirmed (or skipped with `nil`) → paywall.
    func templateDidFinish(templateID: Int?) {
        if let templateID {
            self.templateID = templateID
            store.templateID = templateID
        }
        phase = .premium
    }

    /// Back button on the business / logo / template steps.
    func goBack() {
        switch phase {
        case .businessDetails: phase = .welcome
        case .businessLogo:    phase = .businessDetails
        case .template:        phase = .businessLogo
        default:               break
        }
    }

    /// A (simulated) purchase went through. Inside onboarding this shows the
    /// success dialog; elsewhere the caller navigates to `.premium(.success)`.
    func didPurchasePremium() {
        isPremium = true
        store.isPremium = true
        if phase == .premium {
            phase = .premiumSuccess
        }
    }

    /// Paywall closed, or the success dialog dismissed, inside onboarding.
    func premiumDidFinish() {
        guard phase == .premium || phase == .premiumSuccess else { return }
        phase = .allSet
    }

    /// Last onboarding step → the main app.
    func finishOnboarding() {
        store.hasOnboarded = true
        phase = .home
    }

    /// Dev helper: wipe onboarding state and replay the whole flow.
    /// Handy from a debug button in Settings.
    func resetOnboarding() {
        store.hasOnboarded = false
        phase = .splash
    }

    #if DEBUG
    /// `-uiPreviewPhase <phase>` launch hook: jump straight to a flow phase.
    func debugShow(_ phase: AppPhase) {
        self.phase = phase
    }
    #endif
}

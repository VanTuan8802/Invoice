//
//  AppPhase.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

/// The launch flow shown by `ContainerView`, in order:
/// splash → language → intro → welcome → business details → business logo
/// → template → premium (→ premium success) → all set → home.
/// Returning users go straight from splash to home.
enum AppPhase: String, Equatable, CaseIterable {
    /// Branded loading screen shown on every launch (runs the ad init sequence).
    case splash
    /// First-launch language picker.
    case language
    /// First-launch 4-page onboarding carousel.
    case intro
    /// "Welcome back" + Get Started.
    case welcome
    /// Business name / address / phone (writes `DataStore.business`).
    case businessDetails
    /// Business logo upload (writes `DataStore.business.logoData`).
    case businessLogo
    /// Invoice template picker (kept in `OnboardingStore.templateID`).
    case template
    /// Paywall shown inside the onboarding flow.
    case premium
    /// Paywall success dialog (after a purchase in onboarding).
    case premiumSuccess
    /// "You're All Set!" — last onboarding step.
    case allSet
    /// The main app, rooted at Home.
    case home
}

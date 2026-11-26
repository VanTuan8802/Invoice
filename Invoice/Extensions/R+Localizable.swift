import Foundation
@_exported import RswiftResources   // R.image / R.font / Text(R...) usable without importing in every file

extension _R {
    /// `R.string.localizable` in the language picked in-app (not the device language).
    /// Usage: `R.stringLocalizable.who_for_title()`.
    var stringLocalizable: string.localizable {
        R.string.localizable(preferredLanguages: [OnboardingStore().currentLanguage.rawValue])
    }
}

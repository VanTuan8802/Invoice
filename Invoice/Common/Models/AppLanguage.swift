//
//  AppLanguage.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import Foundation

/// Languages the app ships translations for (one `.lproj` each).
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case vietnamese = "vi"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case japanese = "ja"

    var id: String { rawValue }

    /// Name shown in the user's own language (endonym — not translated).
    var displayName: String {
        switch self {
        case .english:    return "English"
        case .vietnamese: return "Tiếng Việt"
        case .spanish:    return "Español"
        case .french:     return "Français"
        case .german:     return "Deutsch"
        case .japanese:   return "日本語"
        }
    }

    /// Flag emoji used as a lightweight inline icon (e.g. Settings rows).
    var flag: String {
        switch self {
        case .english:    return "🇬🇧"
        case .vietnamese: return "🇻🇳"
        case .spanish:    return "🇪🇸"
        case .french:     return "🇫🇷"
        case .german:     return "🇩🇪"
        case .japanese:   return "🇯🇵"
        }
    }

    /// 32×24 flag artwork from the design (language picker rows).
    var flagImage: RswiftResources.ImageResource {
        switch self {
        case .english:    return R.image.ic_onboarding_flag_en
        case .vietnamese: return R.image.ic_onboarding_flag_vi
        case .spanish:    return R.image.ic_onboarding_flag_es
        case .french:     return R.image.ic_onboarding_flag_fr
        case .german:     return R.image.ic_onboarding_flag_de
        case .japanese:   return R.image.ic_onboarding_flag_ja
        }
    }

    /// Best match for the device's current language, falling back to English.
    static var deviceDefault: AppLanguage {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return AppLanguage(rawValue: code) ?? .english
    }
}

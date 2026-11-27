//
//  SettingsCurrency.swift
//  Invoice
//
//  Currencies offered by the Unit screen's picker (flag + code + symbol).
//  Names come from the system, localized in the in-app language.
//

import Foundation

struct SettingsCurrency: Identifiable {
    let code: String
    /// Short symbol shown on the trailing side ("$", "€").
    let symbol: String
    let flag: RswiftResources.ImageResource

    var id: String { code }

    /// Full currency name in the in-app language ("US Dollar").
    var name: String {
        let locale = Locale(identifier: OnboardingStore().currentLanguage.rawValue)
        return locale.localizedString(forCurrencyCode: code) ?? code
    }

    /// "USD ($)" — the value shown on the Unit screen.
    var codeAndSymbol: String { "\(code) (\(symbol))" }

    static let all: [SettingsCurrency] = [
        SettingsCurrency(code: "USD", symbol: "$", flag: R.image.img_settings_flag_usd),
        SettingsCurrency(code: "EUR", symbol: "€", flag: R.image.img_settings_flag_eur),
        SettingsCurrency(code: "JPY", symbol: "¥", flag: R.image.img_settings_flag_jpy),
        SettingsCurrency(code: "GBP", symbol: "£", flag: R.image.img_settings_flag_gbp),
        SettingsCurrency(code: "AUD", symbol: "$", flag: R.image.img_settings_flag_aud),
        SettingsCurrency(code: "CAD", symbol: "$", flag: R.image.img_settings_flag_cad),
        SettingsCurrency(code: "CHF", symbol: "₣", flag: R.image.img_settings_flag_chf),
        SettingsCurrency(code: "CNY", symbol: "¥", flag: R.image.img_settings_flag_cny),
        SettingsCurrency(code: "HKD", symbol: "$", flag: R.image.img_settings_flag_hkd),
    ]

    static func find(_ code: String) -> SettingsCurrency? {
        all.first { $0.code == code }
    }

    /// "USD ($)" for known codes, the bare code otherwise.
    static func display(_ code: String) -> String {
        find(code)?.codeAndSymbol ?? code
    }
}

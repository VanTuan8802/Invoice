//
//  PhoneRegion.swift
//  Invoice
//
//  Country calling codes offered by the phone field's region menu
//  (`BusinessProfile.phoneRegion` stores the ISO code, e.g. "VN").
//

import Foundation

struct PhoneRegion: Identifiable, Hashable {
    /// ISO 3166-1 alpha-2 code shown in the field ("VN").
    let code: String
    /// International dialing prefix shown before the number ("+84").
    let dialCode: String

    var id: String { code }

    /// Localized country name for the menu (e.g. "Vietnam").
    var countryName: String {
        Locale(identifier: OnboardingStore().currentLanguage.rawValue)
            .localizedString(forRegionCode: code) ?? code
    }

    static let all: [PhoneRegion] = [
        PhoneRegion(code: "VN", dialCode: "+84"),
        PhoneRegion(code: "US", dialCode: "+1"),
        PhoneRegion(code: "GB", dialCode: "+44"),
        PhoneRegion(code: "CA", dialCode: "+1"),
        PhoneRegion(code: "AU", dialCode: "+61"),
        PhoneRegion(code: "ES", dialCode: "+34"),
        PhoneRegion(code: "FR", dialCode: "+33"),
        PhoneRegion(code: "DE", dialCode: "+49"),
        PhoneRegion(code: "IT", dialCode: "+39"),
        PhoneRegion(code: "PT", dialCode: "+351"),
        PhoneRegion(code: "BR", dialCode: "+55"),
        PhoneRegion(code: "JP", dialCode: "+81"),
        PhoneRegion(code: "KR", dialCode: "+82"),
        PhoneRegion(code: "CN", dialCode: "+86"),
        PhoneRegion(code: "IN", dialCode: "+91"),
        PhoneRegion(code: "ID", dialCode: "+62"),
        PhoneRegion(code: "MY", dialCode: "+60"),
        PhoneRegion(code: "SG", dialCode: "+65"),
        PhoneRegion(code: "TH", dialCode: "+66"),
        PhoneRegion(code: "PH", dialCode: "+63")
    ]

    /// Region for an ISO code, falling back to the device region, then Vietnam.
    static func region(for code: String?) -> PhoneRegion {
        if let code, let match = all.first(where: { $0.code == code }) { return match }
        let device = Locale.current.region?.identifier
        return all.first { $0.code == device } ?? all[0]
    }
}

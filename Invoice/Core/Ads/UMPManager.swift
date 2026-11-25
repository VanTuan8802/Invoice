//
//  UMPManager.swift
//  Guru cleaner
//
//  Created by Đức Mạnh on 10/03/2026.
//

import Foundation
import UserMessagingPlatform
import FirebaseAnalytics
import SwiftUI
import AppLovinSDK

final class UMPManager {
    static let shared = UMPManager()

    private init() {}

    @MainActor
    func requestConsentIfNeeded() async {
        do {
            let parameters = RequestParameters()
            parameters.isTaggedForUnderAgeOfConsent = false

            try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)

            let status = ConsentInformation.shared.consentStatus
            let formAvailable = ConsentInformation.shared.formStatus == .available

            if formAvailable && (status == .required || status == .unknown) {
                let form = try await loadConsentForm()
                try await presentForm(form)
            }

        } catch {
            logger(error: "UMP consent update failed: \(error.localizedDescription)")
        }

        // [CUSTOM] Mediation privacy — đẩy consent xuống AppLovin adapter (checklist
        // Ads Kit mục 6). Set SAU UMP để phản ánh đúng lựa chọn của user; ngoài EEA
        // (.notRequired) coi như có consent. AppLovinSDK kéo transitive qua AppLovinAdapter.
        let consentStatus = ConsentInformation.shared.consentStatus
        let hasConsent = consentStatus == .obtained || consentStatus == .notRequired
        ALPrivacySettings.setHasUserConsent(hasConsent)
        ALPrivacySettings.setDoNotSell(false)
    }

    /// `+loadWithCompletionHandler:` UMP header ghi rõ "Must be called on the main queue".
    /// `@MainActor` để Swift giữ continuation trên main thread khi caller await.
    @MainActor
    private func loadConsentForm() async throws -> ConsentForm {
        return try await withCheckedThrowingContinuation { continuation in
            ConsentForm.load { form, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let form = form {
                    continuation.resume(returning: form)
                } else {
                    continuation.resume(throwing: NSError(domain: "UMP", code: 999, userInfo: [NSLocalizedDescriptionKey: "Form not available"]))
                }
            }
        }
    }

    @MainActor
    private func presentForm(_ form: ConsentForm) async throws {
        let rootVC = try await getRootViewController()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            form.present(from: rootVC) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }

                let status = ConsentInformation.shared.consentStatus
                if status == .obtained {
                    Analytics.logEvent("user_consent", parameters: [:])
                    logger(message: "UMP consent obtained")
                } else {
                    Analytics.logEvent("user_not_consent", parameters: [:])
                    logger(message: "UMP consent not obtained")
                }
            }
        }
    }

    @MainActor
    private func getRootViewController() async throws -> UIViewController {
        // Mở rộng điều kiện tìm Scene: Ngay lúc SplashView mới khởi tạo, Scene có thể chưa kịp chuyển sang foregroundActive mà vẫn là foregroundInactive
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            throw NSError(domain: "UMP", code: 998, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        return rootVC
    }
}



//
//  AdUtil.swift
//  AdmobSwitUI
//
//  Created by Đức Mạnh on 10/03/2026.
//

import Foundation
import ads_swift

enum AdUtil {

    static var config: AdUnitsConfig {
        return RemoteConfigManager.shared.adConfig.adUnitsConfig
    }

    // MARK: - Ads
    @MainActor
    static func showInter(config: AdUnitConfig,
                          onDone: @escaping () -> Void) {
        guard config.isEnable else {
            return onDone()
        }

        AdsManager.shared.showInterstitialAd(
            adUnitID: config.id,
            onDismissed: onDone,
            onFailed: { _ in
                onDone()
            }, showLoading: false
        )
    }

    @MainActor
    static func showOpen(config: AdUnitConfig,
                         onDone: @escaping () -> Void) {
        guard config.isEnable else {
            return onDone()
        }

        AdsManager.shared.showAppOpenAd(
            adUnitID: config.id,
            onDismissed: onDone,
            onFailed: { _ in
                onDone()
            }
        )
    }

    @MainActor
    static func showReward(config: AdUnitConfig,
                           onDone: @escaping (Bool) -> Void) {
        guard config.isEnable else { onDone(true); return }
        AdsManager.shared.showRewardedAd(
            adUnitID: config.id,
            onDismissed: { rewarded in
                onDone(rewarded)
            }
        )
    }

    /// Tắt tạm app-open ad cho tới khi user quay lại app (vd: khi mở Safari /
    /// App Store từ trong app). Gọi từ `.environment(\.openURL)` hook.
    static func suppressAdsUntilReturn() {
        AdsManager.shared.appLifecycleReactor?.setIsExcludeScreen(true)
    }
}


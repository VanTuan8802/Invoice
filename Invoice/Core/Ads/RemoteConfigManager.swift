//
//  ConfigAdMobManager.swift
//  AdmobSwitUI
//
//  Created by DucManh on 10/03/2026.
//

import Foundation
import FirebaseRemoteConfig

// MARK: - Ad Unit Config Models (Moved to ad_config directory)

// MARK: - Remote Config Key
enum RemoteConfigType: CaseIterable {
    case adConfig
    case appConfig

    var key: String {
        switch self {
        case .adConfig: return "ad_config"
        case .appConfig: return "app_configs"
        }
    }
}

// MARK: - Remote Config Manager

class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    var adConfig: AdConfig = AdConfig()
    var appConfig: AppConfig = AppConfig()
    var nativeAllConfig: NativeAllConfig = NativeAllConfig()

    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        loadDefaultValues()
        _ = AdRevenueLogger.shared
    }

    // MARK: - Private Methods
    private func loadDefaultValues() {
        getConfigValue()
    }

    private func getConfigValue(completed: @escaping () -> () = {}) {
        decodeAdConfig()
        decodeAppConfig()
        completed()
    }

    private func decodeAdConfig() {
        let configString = remoteConfig.configValue(forKey: RemoteConfigType.adConfig.key).stringValue
        guard !configString.isEmpty else { return }
        guard let data = configString.data(using: .utf8) else {
            logger(error: "Invalid ad_config string"); return
        }
        do {
            adConfig = try JSONDecoder().decode(AdConfig.self, from: data)
            if let extraKeys = adConfig.adUnitsConfig.interAll.extraKeys {
                InterHomeUtil.instance.config = InterHomeConfig(from: extraKeys)
            }
            if let extraKeys = adConfig.adUnitsConfig.rewardAll.extraKeys {
                RewardAllUtil.instance.config = RewardAllConfig(from: extraKeys)
            }
            if let extraKeys = adConfig.adUnitsConfig.nativeAll.extraKeys {
                nativeAllConfig = NativeAllConfig(from: extraKeys)
            }
            logger(message: "✅ Ad config loaded")
        } catch {
            logger(error: "Error decoding AdConfig: \(error)")
        }
    }

    private func decodeAppConfig() {
        let configString = remoteConfig.configValue(forKey: RemoteConfigType.appConfig.key).stringValue
        guard !configString.isEmpty else { return }
        guard let data = configString.data(using: .utf8) else {
            logger(error: "Invalid app_configs string"); return
        }
        do {
            appConfig = try JSONDecoder().decode(AppConfig.self, from: data)
            logger(message: "✅ App config loaded")
        } catch {
            logger(error: "Error decoding AppConfig: \(error)")
        }
    }

    /// DEBUG: fetch mỗi lần để test config tức thì.
    /// RELEASE: 1h — `minimumFetchInterval = 0` trên bản live sẽ bị Firebase
    /// throttle (5 fetch/giờ/thiết bị), fetch lỗi → phải xài config cache.
    private func applyFetchSettings() {
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
    }

    var enableAllAds: Bool {
       
        return adConfig.showAllAds
    }

    // MARK: - Fetch
    func fetchAndActivate(completed: @escaping () -> ()) {
        applyFetchSettings()
        remoteConfig.fetchAndActivate { [weak self] status, error in
            if let error = error {
                logger(error: "Remote Config fetch error: \(error)")
            } else {
                logger(message: "✅ Remote Config fetched & activated (status: \(status))")
            }
            self?.getConfigValue()
            DispatchQueue.main.async { completed() }
        }
    }

    func fetchCloudValues(completed: @escaping () -> ()) {
        fetchAndActivate(completed: completed)
    }
}

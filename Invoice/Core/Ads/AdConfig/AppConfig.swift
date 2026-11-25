//
//  AppConfig.swift
//  AdmobSwitUI
//
//  Decode từ key Remote Config `app_configs` (tách khỏi `ad_config`).
//  Chứa các cờ vận hành app.
//

import Foundation

struct AppConfig: Codable {

    var appToken: String = ""
    var eventToken: String = ""

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        appToken = try c.decodeIfPresent(String.self, forKey: .appToken) ?? ""
        eventToken = try c.decodeIfPresent(String.self, forKey: .eventToken) ?? ""
    }
}

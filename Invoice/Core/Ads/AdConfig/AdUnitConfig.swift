//
//  AdUnitConfig.swift
//  AdmobSwitUI
//
//  Created by DucManh on 10/03/2026.
//

import Foundation

struct AdUnitConfig: Codable {
    var id: String = ""
    var enable: Bool = true
    var opacity: Int = 0
    var extraKeys: [String: Bool]?

    /// Slot của ad unit trong `AdUnitsConfig`, gán lúc decode (xem
    /// `AdUnitsConfig.init(from:)`). Dùng để chặn ads khi app đang bị review —
    /// chặn theo PLACEMENT, KHÔNG theo `id`, vì nhiều placement có thể dùng
    /// chung một ad unit id (chặn theo id sẽ tắt nhầm toàn bộ ads).
    /// Rỗng cho `AdUnitConfig()` mặc định (chưa qua decode).
    var placement: String = ""

    enum CodingKeys: String, CodingKey {
        case id, enable, opacity
        case extraKeys
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        enable = try container.decodeIfPresent(Bool.self, forKey: .enable) ?? true
        opacity = try container.decodeIfPresent(Int.self, forKey: .opacity) ?? 0
        extraKeys = try container.decodeIfPresent([String: Bool].self, forKey: .extraKeys)
    }

    init() {}
}

extension AdUnitConfig {
    /// Ad được phép hiển thị: master switch (`enableAllAds`) && cờ `enable` riêng.
    /// MỌI call-site show ad PHẢI dùng `isEnable`, không đọc thẳng `enable`.
    var isEnable: Bool {
        let mgr = RemoteConfigManager.shared
        return mgr.enableAllAds && enable
    }
}

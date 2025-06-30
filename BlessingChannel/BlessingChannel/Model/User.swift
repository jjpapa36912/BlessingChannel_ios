//
//  User.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//

import Foundation
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let isGuest: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isGuest = "guest"
    }

    // ✅ 디코딩용 이니셜라이저
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idInt = try container.decode(Int.self, forKey: .id)
        self.id = String(idInt)
        self.name = try container.decode(String.self, forKey: .name)
        self.isGuest = try container.decode(Bool.self, forKey: .isGuest)
    }

    // ✅ 수동 생성용 일반 이니셜라이저
    init(id: String, name: String, isGuest: Bool) {
        self.id = id
        self.name = name
        self.isGuest = isGuest
    }
}


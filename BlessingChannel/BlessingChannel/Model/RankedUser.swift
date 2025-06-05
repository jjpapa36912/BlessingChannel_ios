//
//  RankedUser.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/5/25.
//

import Foundation
struct RankedUser: Codable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let point: Int
}

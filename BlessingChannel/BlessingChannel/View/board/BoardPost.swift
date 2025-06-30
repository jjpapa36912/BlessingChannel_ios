//
//  BoardPost.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/7/25.
//

import Foundation

struct BoardPost: Codable, Identifiable {
    let id: Int
    let author: String
    let createdAt: String
    var title: String
    var content: String
    let likes: Int?
    var comments: [Comment]
    var isNotice: Bool
}

//
//struct BoardPost: Identifiable, Codable {
//    let id: Int
//    var title: String
//    var content: String
//    var author: String
//    var createdAt: String
//    var comments: [String]
//    var isNotice: Bool
//}

struct CommentRequest: Codable {
    let author: String
    let content: String
}
//struct Comment: Identifiable, Codable {
//    let id: Int
//    let author: String
//    let content: String
//    var likes: Int?
//    var emoji: String?
//}
struct Comment: Identifiable, Codable, Hashable {
    let id: Int         // ✅ 중복 없이 안정적
    let author: String?
    let content: String
    var likes: Int?
    var emoji: String?
}

//
//  CommentReaction.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/10/25.
//

import Foundation

struct CommentReaction: Identifiable, Hashable {
    let id = UUID()
    let author: String
    var emoji: String?
    var likes: Int
}

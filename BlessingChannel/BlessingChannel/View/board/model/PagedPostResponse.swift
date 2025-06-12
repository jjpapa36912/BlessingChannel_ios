//
//  PagedPostResponse.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/10/25.
//

import Foundation

struct PagedPostResponse: Codable {
    let content: [BoardPost]
    let number: Int
    let totalPages: Int
    let totalElements: Int

    var posts: [BoardPost] { content }
    var currentPage: Int { number }
}


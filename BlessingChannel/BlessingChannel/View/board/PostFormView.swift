//
//  PostFormView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/7/25.
//

import Foundation
import SwiftUI

struct PostFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: BoardViewModel
    let currentUser: String
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                TextField("(선택) 제목을 입력해주세요", text: $title)
                    .padding(.horizontal)

                Divider()

                Text("욕설, 비방 등 상대방을 불쾌하게 하는 의견은 남기지 말아주세요. 신고를 당하면 커뮤니티 이용이 제한될 수 있어요.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                TextEditor(text: $content)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("글 작성")
            .navigationBarItems(trailing: Button("남기기") {
                let newPost = BoardPost(
                    id: (viewModel.posts.map { $0.id }.max() ?? 0) + 1,
                    author: currentUser,
                    createdAt: "방금 전",
                    title: title,
                    content: content,
                    likes: 0,
                    comments: []
                )
                viewModel.posts.insert(newPost, at: 0)
                dismiss()
            }.disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
        }
    }
}

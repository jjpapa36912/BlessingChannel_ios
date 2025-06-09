//
//  PostCardView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/8/25.
//

import Foundation

import SwiftUI

struct PostCardView: View {
    let post: BoardPost
    let currentUser: String
    @Binding var expandedPostId: Int?
    @Binding var activeReactionPostId: Int?
    @Binding var commentTexts: [Int: String]
    @Binding var selectedEmoji: [Int: String]
    @ObservedObject var viewModel: BoardViewModel

    var body: some View {
        let isExpanded = expandedPostId == post.id
        let isReacting = activeReactionPostId == post.id
        let commentText = commentTexts[post.id] ?? ""

        return VStack(alignment: .leading, spacing: 8) {
            // 작성자, 제목, 시간
            HStack(alignment: .top) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading) {
                    HStack {
                        Text(post.author).fontWeight(.bold)
                        if !post.title.isEmpty {
                            Text("· \(post.title)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    Text(post.createdAt)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Text(isExpanded || post.content.count <= 100 ? post.content : post.content.prefix(100) + "...")

            if post.content.count > 100 {
                Button(isExpanded ? "접기" : "더 보기") {
                    expandedPostId = isExpanded ? nil : post.id
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            // 하단 아이콘
            HStack(spacing: 16) {
                Label("\(post.likes)", systemImage: "heart")
                Button {
                    activeReactionPostId = post.id
                } label: {
                    Label("\(post.comments.count)", systemImage: "message")
                }
                Image(systemName: "arrow.2.squarepath")
                Spacer()
                Menu {
                    Button("수정") {}
                    Button("삭제", role: .destructive) {
                        viewModel.deletePost(id: post.id)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            .font(.subheadline)
            .foregroundColor(.gray)

            // 댓글 및 이모지 입력 바
            if isReacting {
                VStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(["📈", "📉", "❤️", "👍", "🙏", "😀", "😢"], id: \.self) { emoji in
                                Text(emoji)
                                    .font(.largeTitle)
                                    .onTapGesture {
                                        selectedEmoji[post.id] = emoji
                                    }
                                    .background(
                                        Circle()
                                            .fill(selectedEmoji[post.id] == emoji ? Color.blue.opacity(0.3) : Color.clear)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }

                    HStack {
                        Image(systemName: "person.circle.fill")
                        TextField("\(currentUser)님의 생각을 적어주세요", text: Binding(
                            get: { commentTexts[post.id] ?? "" },
                            set: { commentTexts[post.id] = $0 }
                        ))

                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)

                        if !commentText.trimmingCharacters(in: .whitespaces).isEmpty {
                            Button {
                                viewModel.addComment(postId: post.id, comment: "\(currentUser): \(commentText)")
                                commentTexts[post.id] = ""
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}





import SwiftUI

struct PostCardView: View {
    let post: BoardPost
    let currentUserId: String
    let currentUser: String
    let isGuest: Bool 
    @Binding var activeReactionPostId: Int?
    @Binding var commentTexts: [Int: String]
    @Binding var selectedEmoji: [Int: String]
    // ⚠️ delete 파라미터: postId, commentId, author, userId
    var onCommentAdd: (Int, String, String, String) -> Void

        var onCommentDelete: (Int, Int, String, String) -> Void
    var onEmojiReact: (Int, Int, String) -> Void
    

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(post.title)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)

                    Spacer()

                    if post.isNotice {
                        Text("공지")
                            .font(.caption2)
                            .padding(4)
                            .background(Color.yellow.opacity(0.4))
                            .cornerRadius(4)
                            .foregroundColor(.black)
                    }
                }

                Text(post.content)
                    .font(.body)
                    .foregroundColor(.white) // ✅ 중복된 .foregroundColor 제거

                HStack {
                    Text("by \(post.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(post.createdAt)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Divider()

                ForEach(post.comments, id: \.id) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(comment.author): \(comment.content)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                            if comment.author == currentUser {
                                Button(action: {
                                    onCommentDelete(post.id, comment.id, currentUser, currentUserId)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        HStack {
                            // ✅ 잘못된 onCommentDelete.id → post.id로 수정
                            Button("😀") { onEmojiReact(post.id, comment.id, "😀") }
                            Button("👍") { onEmojiReact(post.id, comment.id, "👍") }
                            Button("❤️") { onEmojiReact(post.id, comment.id, "❤️") }
                        }
                        .font(.caption)
                    }
                }

                if !isGuest {
                    HStack {
                        TextField("댓글을 입력하세요", text: Binding(
                            get: { commentTexts[post.id] ?? "" },
                            set: { newVal in commentTexts[post.id] = newVal }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("등록") {
                            if let text = commentTexts[post.id], !text.isEmpty {
                                // ✅ 수정됨: userId와 userName 함께 전달
                                onCommentAdd(post.id, currentUserId, currentUser, text)
                                commentTexts[post.id] = ""
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(radius: 2)
            .padding(.vertical, 5)
        }
}

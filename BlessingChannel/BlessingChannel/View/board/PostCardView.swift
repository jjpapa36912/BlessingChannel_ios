



import SwiftUI

struct PostCardView: View {
    let post: BoardPost
    let currentUser: String
    let isGuest: Bool 
    @Binding var activeReactionPostId: Int?
    @Binding var commentTexts: [Int: String]
    @Binding var selectedEmoji: [Int: String]
    var onCommentAdd: (Int, String) -> Void
    var onCommentDelete: (Int, Int, String) -> Void
    var onEmojiReact: (Int, Int, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(post.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.black) // ✅ 제목 글자색 진하게

                Spacer()
                if post.isNotice {
                    Text("공지")
                        .font(.caption2)
                        .padding(4)
                        .background(Color.yellow.opacity(0.4))
                        .cornerRadius(4)
                        .foregroundColor(.black) // ✅ 제목 글자색 진하게

                }
            }

            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .foregroundColor(.white) // ✅ 제목 글자색 진하게


            HStack {
                Text("by \(post.author)")
                    .font(.caption)
                    .foregroundColor(.gray) // ✅ 보조 텍스트는 연한 회색
                Spacer()
                Text(post.createdAt)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Divider()

            ForEach(post.comments) { comment in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(comment.author): \(comment.content)")
                            .font(.subheadline)
                            .foregroundColor(.white) // ✅ 댓글도 진한 색으로
                        Spacer()
                        if comment.author == currentUser {
                            Button(action: {
                                onCommentDelete(post.id, comment.id, currentUser)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    HStack {
                        Button("😀") { onEmojiReact(post.id, comment.id, "😀") }
                        Button("👍") { onEmojiReact(post.id, comment.id, "👍") }
                        Button("❤️") { onEmojiReact(post.id, comment.id, "❤️") }
                    }
                    .font(.caption)
                }
            }
            if !isGuest {
                HStack {
                    TextField("댓글을 입력하세요", text: Binding(get: {
                        commentTexts[post.id] ?? ""
                    }, set: { newVal in
                        commentTexts[post.id] = newVal
                    }))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("등록") {
                        if let text = commentTexts[post.id], !text.isEmpty {
                            onCommentAdd(post.id, text)
                            commentTexts[post.id] = ""
                        }
                    }
                }}
        }
        .padding()
        .background(Color(UIColor.systemGray6)) // ✅ 배경을 연회색으로
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
        .padding(.vertical, 5)
    }
}

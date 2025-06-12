import SwiftUI


struct BoardMainView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = BoardViewModel()
    @State private var searchText = ""
    @State private var showSearchBar = false
    @State private var showMyPosts = false
    @State private var expandedPostId: Int? = nil
    @State private var showPostForm = false
    @State private var activeReactionPostId: Int? = nil
    @State private var commentTexts: [Int: String] = [:]
    @State private var selectedEmoji: [Int: String] = [:]
    @State private var selectedPostForEdit: BoardPost? = nil
    @State private var currentPage = 0
    let user: User
    var currentUser: String { user.name }

    var filteredPosts: [BoardPost] {
        let base = showMyPosts ? viewModel.posts.filter { $0.author == currentUser } : viewModel.posts
        return searchText.isEmpty ? base : base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        print("🔙 뒤로가기 버튼 클릭됨")

                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }

                    Text(showMyPosts ? "내 글 보기" : "전체 글")
                        .font(.title2).bold()
                        .padding(.leading, 4)

                    Spacer()

                    Button(action: { showMyPosts.toggle() }) {
                        
                        Text(showMyPosts ? "전체 글 보기" : "내 글만 보기")
                            .font(.subheadline)
                    }

                    Button(action: {
                        selectedPostForEdit = nil
                        showPostForm = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                            .padding(.leading, 8)
                    }
                }
                .padding()

                if showSearchBar {
                    TextField("검색어를 입력하세요", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .bottom])
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPosts) { post in
                            PostCardView(
                                post: post,
                                currentUser: currentUser,
                                isGuest: user.isGuest, // 이 줄 추가
                                activeReactionPostId: $activeReactionPostId,
                                commentTexts: $commentTexts,
                                selectedEmoji: $selectedEmoji,
                                onCommentAdd: { postId, text in
                                    viewModel.addComment(postId: postId, author: currentUser, content: text) // ✅ 순서 일치
                                },
                                onCommentDelete: { postId, commentId, author in
                                    viewModel.deleteComment(postId: postId, commentId: commentId, author: author)
                                },
                                onEmojiReact: { postId, commentId, emoji in
                                    viewModel.reactToComment(postId: postId, commentId: commentId, emoji: emoji, author: currentUser)
                                }
                            )
                        }

                        if viewModel.hasMorePages {
                            Button("더 보기") {
                                viewModel.fetchNextPage()
                            }
                            .padding(.vertical)
                        }

                    }
                    .padding(.horizontal)
                }

                .sheet(isPresented: $showPostForm, onDismiss: {
                    viewModel.refreshPosts() // ✅ 글 작성 or 수정 후 새로고침
                }) {
                    PostFormView(viewModel: viewModel, currentUser: currentUser, editingPost: selectedPostForEdit)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showSearchBar.toggle()
                        }
                    }) {
                        Image(systemName: showSearchBar ? "xmark.circle.fill" : "magnifyingglass")
                    }
                }
            }
            .onAppear {
                print("📌 BoardMainView appeared, fetching page \(currentPage)")

                viewModel.refreshPosts()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

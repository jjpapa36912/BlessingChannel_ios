// BoardMainView.swift

// BoardMainView.swift

// BoardMainView.swift
// BoardMainView.swift
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
    let currentUser: String

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
                // 상단 메뉴바
                HStack {
                    Button(action: {
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
                        showPostForm = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                            .padding(.leading, 8)
                    }
                }
                .padding()

                // 검색창
                if showSearchBar {
                    TextField("검색어를 입력하세요", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .bottom])
                }

                // 게시글 리스트
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPosts) { post in
                            PostCardView(
                                post: post,
                                currentUser: currentUser,
                                expandedPostId: $expandedPostId,
                                activeReactionPostId: $activeReactionPostId,
                                commentTexts: $commentTexts,
                                selectedEmoji: $selectedEmoji,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // 글쓰기 폼
                .sheet(isPresented: $showPostForm) {
                    PostFormView(viewModel: viewModel, currentUser: currentUser)
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

////
////  BoardScreenView.swift
////  BlessingChannel
////
////  Created by 김동준 on 6/7/25.
////
//
//import Foundation
//import SwiftUI
//
//struct BoardScreenView: View {
//    let currentUser: String
//    @StateObject private var viewModel = BoardViewModel()
//    @State private var showForm = false
//    @State private var editingPost: BoardPost? = nil
//    @State private var commentTexts: [Int: String] = [:] // 게시글 ID별로 입력값 관리
//    @State private var showMyPosts = false
//
//    var sortedPosts: [BoardPost] {
//        viewModel.posts.sorted { (a: BoardPost, b: BoardPost) -> Bool in
//            if a.author == currentUser && b.author != currentUser {
//                return true
//            } else if a.author != currentUser && b.author == currentUser {
//                return false
////            } else if a.isNotice != b.isNotice {
////                return a.isNotice
//            } else {
//                return a.id > b.id
//            }
//        }
//    }
//
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    HStack {
//                        Text("\u{1F4CB} 게시판")
//                            .font(.title2)
//                            .bold()
//
//                        Spacer()
//
//                        Button(action: {
//                            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
//                        }) {
//                            Text("\u{1F3E0} 홈으로")
//                        }
//                    }
//
//                    HStack {
//                        Button("\u{270D}\u{FE0F} 글 작성하기") {
//                            editingPost = nil
//                            showForm = true
//                        }
//                        .frame(maxWidth: .infinity)
//                        .buttonStyle(.borderedProminent)
//
//                        Button(showMyPosts ? "전체 글 보기" : "내 글만 보기") {
//                            showMyPosts.toggle()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .buttonStyle(.bordered)
//                        .tint(showMyPosts ? .gray : .blue)
//                    }
//
//                    ForEach(showMyPosts ? sortedPosts.filter { $0.author == currentUser } : sortedPosts) { post in
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text(post.title)
//                                .font(.headline)
//
//                            if post.isNotice && post.author == currentUser {
//                                Text("[공지사항]")
//                                    .font(.caption)
//                                    .foregroundColor(.red)
//                            }
//
//                            Text(post.content)
//                                .lineLimit(2)
//
//                            Text("- \(post.author), \(post.createdAt)")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//
//                            if post.author == currentUser {
//                                HStack {
//                                    Button("수정하기") {
//                                        editingPost = post
//                                        showForm = true
//                                    }
//                                    Button("삭제하기") {
//                                        viewModel.deletePost(id: post.id)
//                                    }
//                                    .foregroundColor(.red)
//                                }
//                            }
//
//                            Text("\u{1F4AC} 댓글")
//                                .font(.subheadline)
//                                .bold()
//
//                            ForEach(post.comments, id: \.self) { comment in
//                                HStack {
//                                    Text("- \(comment)")
//                                    if comment.hasPrefix("\(currentUser):") {
//                                        Button("삭제") {
//                                            viewModel.deleteComment(postId: post.id, comment: comment)
//                                        }
//                                        .font(.caption)
//                                        .foregroundColor(.red)
//                                    }
//                                }
//                            }
//
//                            TextField("댓글을 입력하세요", text: Binding(
//                                                            get: { commentTexts[post.id] ?? "" },
//                                                            set: { commentTexts[post.id] = $0 }
//                                                        ))
//                                                        .padding(8)
//                                                        .background(Color.white)
//                                                        .cornerRadius(6)
//                                                        .foregroundColor(.black)
//                                                        .background(Color(UIColor.systemGray6))
//                                                        .foregroundColor(.primary)
//
//                            Button("댓글 등록") {
//                                if let comment = commentTexts[post.id], !comment.isEmpty {
//                                    viewModel.addComment(postId: post.id, comment: "\(currentUser): \(comment)")
//                                    commentTexts[post.id] = ""
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    }
//
//                    if showForm {
//                        PostFormView(
//                            post: editingPost,
//                            currentUser: currentUser,
//                            onSubmit: { title, content in
//                                if let editing = editingPost {
//                                    viewModel.updatePost(id: editing.id, title: title, content: content, author: currentUser)
//                                } else {
//                                    viewModel.addPost(title: title, content: content, author: currentUser)
//                                }
//                                showForm = false
//                                editingPost = nil
//                            },
//                            onCancel: {
//                                showForm = false
//                                editingPost = nil
//                            }
//                        )
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("게시판")
//        }
//        .navigationViewStyle(StackNavigationViewStyle()) // ✅ iPad 전체화면 대응
//    }
//}

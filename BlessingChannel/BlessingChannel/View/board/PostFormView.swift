//
//  PostFormView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/7/25.
//

import Foundation
import SwiftUI

struct PostFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BoardViewModel
    let currentUser: String
    var editingPost: BoardPost? = nil

    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle(editingPost == nil ? "글 작성" : "글 수정")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    if let post = editingPost {
                        viewModel.updatePost(id: post.id, title: title, content: content, author: currentUser)
                    } else {
                        viewModel.addPost(title: title, content: content, author: currentUser)
                    }
                    presentationMode.wrappedValue.dismiss()
                    viewModel.refreshPosts()
                }
                .disabled(title.isEmpty || content.isEmpty)
            )
        }
        .onAppear {
            if let post = editingPost {
                title = post.title
                content = post.content
            }
        }
    }
}


//
//  PostFormView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/7/25.
//

import Foundation
import SwiftUI

struct PostFormView: View {
    var post: BoardPost?
    var currentUser: String
    var onSubmit: (String, String) -> Void
    var onCancel: () -> Void

    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("제목", text: $title)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $content)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )

            HStack {
                Button("취소", action: onCancel)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray)
                    .cornerRadius(8)

                Spacer()

                Button(post == nil ? "등록" : "수정 완료") {
                    onSubmit(title, content)
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onAppear {
            title = post?.title ?? ""
            content = post?.content ?? ""
        }
    }
}

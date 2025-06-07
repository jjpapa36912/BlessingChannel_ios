//
//  BoardViewModel.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/7/25.
//

import Foundation
import Foundation
import Combine

class BoardViewModel: ObservableObject {
    @Published var posts: [BoardPost] = []

    init() {
        fetchPostsFromServer()
    }

    func fetchPostsFromServer() {
        guard let url = URL(string: "\(API.baseURL)/api/posts") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        let postList = jsonArray.compactMap { dict -> BoardPost? in
                            guard let id = dict["id"] as? Int,
                                  let title = dict["title"] as? String,
                                  let content = dict["content"] as? String,
                                  let author = dict["author"] as? String,
                                  let createdAt = dict["createdAt"] as? String else { return nil }

                            let comments = (dict["comments"] as? [String]) ?? []
                            let isNotice = dict["isNotice"] as? Bool ?? (author == "김동준")

                            return BoardPost(
                                id: id,
                                title: title,
                                content: content,
                                author: author,
                                createdAt: createdAt,
                                comments: comments,
                                isNotice: isNotice
                            )
                        }
                        DispatchQueue.main.async {
                            self.posts = postList
                        }
                    }
                } catch {
                    print("❌ 게시글 파싱 실패: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    func addPost(title: String, content: String, author: String) {
        guard let url = URL(string: "\(API.baseURL)/api/posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let isNotice = (author == "김동준")
        let json: [String: Any] = [
            "title": title,
            "content": content,
            "author": author,
            "isNotice": isNotice
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self.fetchPostsFromServer()
            } else {
                print("❌ 글 등록 실패")
            }
        }.resume()
    }

    func updatePost(id: Int, title: String, content: String, author: String) {
        guard let url = URL(string: "\(API.baseURL)/api/posts/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "title": title,
            "content": content,
            "author": author // ✅ 포함해야 서버에서 isNotice 여부 판단 가능
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                self.fetchPostsFromServer()
            } else {
                print("❌ 글 수정 실패")
            }
        }.resume()
    }


    func deletePost(id: Int) {
        guard let url = URL(string: "\(API.baseURL)/api/posts/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.posts.removeAll { $0.id == id }
            }
        }.resume()
    }

    func addComment(postId: Int, comment: String) {
        guard let url = URL(string: "\(API.baseURL)/api/posts/board/\(postId)/comments") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let author = comment.components(separatedBy: ":").first ?? "익명"
        let content = comment.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)

        let json: [String: Any] = ["author": author, "content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.posts = self.posts.map {
                        if $0.id == postId {
                            var updated = $0
                            updated.comments.append(comment)
                            return updated
                        } else {
                            return $0
                        }
                    }
                }
            } else {
                print("❌ 댓글 등록 실패")
            }
        }.resume()
    }

    func deleteComment(postId: Int, comment: String) {
        guard let url = URL(string: "\(API.baseURL)/api/posts/board/\(postId)/comments") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let author = comment.components(separatedBy: ":").first ?? ""
        let content = comment.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)

        let body: [String: String] = [
            "author": author,
            "content": content
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ 댓글 삭제 실패")
                return
            }
            DispatchQueue.main.async {
                self.posts = self.posts.map {
                    if $0.id == postId {
                        var updated = $0
                        updated.comments.removeAll { $0 == comment }
                        return updated
                    } else {
                        return $0
                    }
                }
            }
        }.resume()
    }

}

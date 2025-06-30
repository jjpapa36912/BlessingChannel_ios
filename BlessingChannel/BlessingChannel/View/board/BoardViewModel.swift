import Foundation
import Combine

class BoardViewModel: ObservableObject {
    @Published var posts: [BoardPost] = []
    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 1
    @Published var isLoading: Bool = false

    init() {
        fetchPostsFromServer()
    }

    func fetchNextPage(reset: Bool = false) {
        guard !isLoading else { return }

        isLoading = true
        let pageToFetch = reset ? 0 : currentPage
        guard let url = URL(string: "\(API.baseURL)/api/posts/paged?page=\(pageToFetch)&size=10") else { return }

        print("📡 게시글 목록 요청: page=\(pageToFetch)")

        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                        print("❌ 게시글 요청 실패: \(error.localizedDescription)")
                        return
                    }
            defer { self.isLoading = false }

            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }

            do {
                let postList = try JSONDecoder().decode([BoardPost].self, from: data)
                DispatchQueue.main.async {
                    if reset {
                        self.posts = postList
                        self.currentPage = 1
                    } else {
                        self.posts += postList
                        self.currentPage += 1
                    }
                    self.hasMorePages = !postList.isEmpty
                }
            } catch {
                print("❌ 디코딩 실패: \(error)")
                print("🔥 응답 원문: \(String(data: data, encoding: .utf8) ?? "N/A")")
            }
        }.resume()
    }


    func refreshPosts() {
        currentPage = 0
        hasMorePages = true
        posts = []
        fetchNextPage(reset: true)
    }

    
    func fetchPostsFromServer(reset: Bool = false) {
            if isLoading || (!reset && !hasMorePages) { return }

            isLoading = true

            let pageToFetch = reset ? 0 : currentPage
            guard let url = URL(string: "\(API.baseURL)/api/posts/paged?page=\(pageToFetch)&size=10") else { return }

            print("📡 게시글 목록 요청: page=\(pageToFetch)")
        
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                            print("❌ 게시글 요청 실패: \(error.localizedDescription)")
                            return
                        }
                defer { self.isLoading = false }

                guard let data = data else {
                    print("❌ 데이터 없음")
                    return
                }

                do {
                    let postList = try JSONDecoder().decode([BoardPost].self, from: data)
                    DispatchQueue.main.async {
                        if reset {
                            self.posts = postList
                            self.currentPage = 1
                        } else {
                            self.posts += postList
                            self.currentPage += 1
                        }
                        self.hasMorePages = !postList.isEmpty
                    }
                } catch {
                    print("❌ 디코딩 실패: \(error)")
                    print("🔥 응답 원문: \(String(data: data, encoding: .utf8) ?? "N/A")")
                }
            }.resume()
        }

    @Published var hasMorePages: Bool = true


    func reactToComment(postId: Int, commentId: Int, emoji: String, author: String) {
        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments/\(commentId)/react") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "author": author,
            "emoji": emoji
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 댓글 리액션 실패: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("✅ 댓글에 리액션 등록 완료")
            }
        }.resume()
    }


    func loadNextPageIfNeeded(currentPost post: BoardPost) {
        guard let lastPost = posts.last, lastPost.id == post.id else { return }
        guard hasMorePages else { return }
        fetchNextPage()
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

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.refreshPosts() // ✅ 교체됨
                }
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
            "author": author
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { _, response, _ in
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

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.posts.removeAll { $0.id == id }
                }
            } else {
                print("❌ 글 삭제 실패")
            }
        }.resume()
    }

//    func addComment(postId: Int, author: String, content: String) {
//        // 1. 로컬 UI 반영 먼저
//        DispatchQueue.main.async {
//            if let index = self.posts.firstIndex(where: { $0.id == postId }) {
//                let newComment = Comment(id: Int.random(in: 10_000...99_999), author: author, content: content, likes: 0, emoji: "")
//                self.posts[index].comments.append(newComment)
//            }
//        }
//
//        // 2. 서버에 실제 요청 전송
//        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let json: [String: Any] = ["author": author, "content": content]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
//
//        URLSession.shared.dataTask(with: request) { _, response, _ in
//            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                print("✅ 댓글 서버 등록 완료")
//            } else {
//                print("❌ 댓글 등록 실패: 서버와 불일치 가능성 있음")
//            }
//        }.resume()
//    }
    
    func addComment(postId: Int, userId: String, userName: String, content: String) {
        // 1. UI에 먼저 반영 (선택)
        DispatchQueue.main.async {
            if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                let newComment = Comment(
                    id: Int.random(in: 10_000...99_999),
                    author: userName,
                    content: content,
                    likes: 0,
                    emoji: ""
                )
                self.posts[index].comments.append(newComment)
            }
        }

        // 2. 서버 요청
        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let userIdLong = Int64(userId) else {
            print("❌ 유효하지 않은 userId: \(userId)")
            return
        }

        let json: [String: Any] = [
            "userId": userIdLong,
            "content": content
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ 댓글 서버 등록 완료")
                } else {
                    print("❌ 댓글 등록 실패 - 상태코드: \(httpResponse.statusCode)")
                    if let data = data, let raw = String(data: data, encoding: .utf8) {
                        print("📦 응답 내용: \(raw)")
                    }
                }
            }
        }.resume()
    }

//    func addComment(postId: Int, userId: String, userName: String, content: String) {
//        // 1. UI에 먼저 반영
//        DispatchQueue.main.async {
//            if let index = self.posts.firstIndex(where: { $0.id == postId }) {
//                let newComment = Comment(
//                    id: Int.random(in: 10_000...99_999),
//                    author: userName,
//                    content: content,
//                    likes: 0,
//                    emoji: ""
//                )
//                self.posts[index].comments.append(newComment)
//            }
//        }
//
//        // 2. 서버 요청 전송
//        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // ✅ userId를 숫자로 변환해서 보냄
//        let json: [String: Any] = [
//            "userId": Int(userId) ?? 0,
//            "content": content
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
//
//        URLSession.shared.dataTask(with: request) { _, response, _ in
//            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                print("✅ 댓글 서버 등록 완료")
//            } else {
//                print("❌ 댓글 등록 실패: 서버와 불일치 가능성 있음")
//            }
//        }.resume()
//    }



//    func deleteComment(postId: Int, commentId: Int, author: String, userId: String) {
//        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments/\(commentId)/with-auth?author=\(author)?userId=\(userId)")
//else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        URLSession.shared.dataTask(with: request) { _, response, _ in
//            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                DispatchQueue.main.async {
//                    if let index = self.posts.firstIndex(where: { $0.id == postId }) {
//                        self.posts[index].comments.removeAll { $0.id == commentId }
//                    }
//                }
//            } else {
//                print("❌ 댓글 삭제 실패")
//            }
//        }.resume()
//    }
    func deleteComment(postId: Int, commentId: Int, author: String, userId: String) {
        // ⚠️ ? → & 로 수정
        guard let url = URL(string: "\(API.baseURL)/api/posts/\(postId)/comments/\(commentId)?author=\(author)&userId=\(userId)") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                        self.posts[index].comments.removeAll { $0.id == commentId }
                    }
                }
            } else {
                print("❌ 댓글 삭제 실패")
            }
        }.resume()
    }

}

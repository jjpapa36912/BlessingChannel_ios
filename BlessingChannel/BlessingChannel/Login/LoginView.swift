//import Foundation
//import SwiftUI
//import GoogleSignIn
////import GoogleSignInSwift
//import AuthenticationServices
//import KakaoSDKUser
//import KakaoSDKAuth
//import NaverThirdPartyLogin
//
//
//struct LoginView: View {
//    private let naverDelegate = NaverLoginDelegate() // ✅ 그냥 속성으로 유지 (retain만 목적이면 충분)
//
//    // MARK: - Naver (미구현)
//    func handleNaverLogin() {
//        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
//           instance.delegate = naverDelegate
//           instance.requestThirdPartyLogin()
//    }
//
//    var body: some View {
//        ZStack {
//            Color(hex: "#FFF5BC").ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                Text("로그인")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color(hex: "#6B3E26"))
//
//                CustomLoginButton(title: "구글 로그인", action: handleGoogleSignIn)
////                CustomLoginButton(title: "카카오 로그인", action: handleKakaoLogin)
////                CustomLoginButton(title: "네이버 로그인", action: handleNaverLogin)
//
//                SignInWithAppleButton(
//                    .signIn,
//                    onRequest: { request in
//                        request.requestedScopes = [.fullName, .email]
//                    },
//                    onCompletion: { result in
//                        switch result {
//                        case .success(let authorization):
//                            handleAppleLogin(authResults: authorization) // ✅ 이 부분이 핵심
//                        case .failure(let error):
//                            print("❌ Apple 로그인 실패: \(error.localizedDescription)")
//                        }
//                    }
//                )
//
//                .signInWithAppleButtonStyle(.black)
//                .frame(height: 45)
//                .cornerRadius(10)
//                .padding(.top, 10)
//            }
//            .padding()
//        }
//        Button(action: {
//            let guestUser = User(id:"",name: "게스트", isGuest: true)
//            navigateToMain(user: guestUser)
//        }) {
//            Text("그냥 한번 둘러볼래요")
//                .foregroundColor(.gray)
//                .font(.subheadline)
//                .underline()
//                .padding(.top, 20)
//        }
//
//    }
//    // MARK: - Apple 로그인 처리
////        func handleAppleLogin(authResults: ASAuthorization) {
////            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
////                    let providerId = credential.user
////                    let name = credential.fullName?.givenName
////                    let email = credential.email
////
////                    // 이름/이메일이 제공될 경우에만 저장
////                    if let name = name {
////                        UserDefaults.standard.set(name, forKey: "userName")
////                    }
////                    if let email = email {
////                        UserDefaults.standard.set(email, forKey: "userEmail")
////                    }
////
////                    // 저장된 값을 fallback으로 사용
////                    let savedName = name ?? UserDefaults.standard.string(forKey: "userName") ?? "이름 없음"
////                    let savedEmail = email ?? UserDefaults.standard.string(forKey: "userEmail") ?? "이메일 없음"
////
////                    let body = [
////                        "provider": "apple",
////                        "providerId": providerId,
////                        "name": savedName,
////                        "email": savedEmail
////                    ]
////                    // 서버로 전송 또는 UI에 사용
////                
//////            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
//////                let name = credential.fullName?.givenName ?? "이름 없음"
//////                let providerId = credential.user
//////                let body = [
//////                    "provider": "apple",
//////                    "providerId": providerId,
//////                    "name": name
//////                ]
//////                let email = credential.email ?? "이메일 없음"
//////                
////                
////
////                print("✅ 애플 로그인 성공 → \(savedName), \(savedEmail)")
////
////                // 필요한 경우 서버 전송 로직 추가 가능
////                // sendAppleTokenToBackend(credential)
////
////                postToServerLoginEndpoint(body: body) { user in
////                    navigateToMain(user: user) // ✅ 서버에서 받은 User(id, name 등)로 이동
////                }
////            }
////        }
//
//    // MARK: - Google 로그인
////    func handleGoogleSignIn() {
////        let config = GIDConfiguration(clientID: "314078962985-bcg7vno6uenkgcskqh1251ts9u7ene8s.apps.googleusercontent.com")
////
////        guard let rootVC = UIApplication.shared.connectedScenes
////            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else {
////            print("❌ rootViewController 가져오기 실패")
////            return
////        }
////
////        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
////            if let error = error {
////                print("❌ 구글 로그인 실패: \(error.localizedDescription)")
////                return
////            }
////
////            guard let user = user else {
////                print("❌ 로그인 결과 없음")
////                return
////            }
////
////            let name = user.profile?.name ?? "이름 없음"
////            let providerId = user.userID ?? ""
////            let body = [
////                "provider": "google",
////                "providerId": providerId,
////                "name": name
////            ]
////            
////            let email = user.profile?.email ?? "이메일 없음"
////            print("✅ 구글 로그인 성공 → \(name), \(email)")
////
////            postToServerLoginEndpoint(body: body) { user in
////                navigateToMain(user: user) // ✅ 서버에서 받은 User(id, name 등)로 이동
////            }
////        }
////    }
//
////        guard let rootVC = UIApplication.shared.connectedScenes
////            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else { return }
////
////        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
////            if let error = error {
////                print("❌ 구글 로그인 실패: \(error.localizedDescription)")
////                return
////            }
////
////            guard let profile = result?.user.profile else {
////                print("❌ 사용자 프로필 정보 없음")
////                return
////            }
////
////            let name = profile.name ?? "이름 없음"
////            let email = profile.email ?? "이메일 없음"
////            print("✅ 구글 로그인 성공 → \(name), \(email)")
////
////            navigateToMain(user: User(name: name))
////        }
//    }
//
////func postToServerLoginEndpoint(body: [String: Any], completion: @escaping (User) -> Void) {
////    guard let url = URL(string: "\(API.baseURL)/api/auth/social-login") else { return }
////
////    var request = URLRequest(url: url)
////    request.httpMethod = "POST"
////    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
////
////    URLSession.shared.dataTask(with: request) { data, response, error in
////        if let error = error {
////            print("❌ 요청 실패: \(error.localizedDescription)")
////            return
////        }
////
////        guard let data = data else {
////            print("❌ 응답 없음")
////            return
////        }
////
////        do {
////            // 👇 디코딩 실패 시 로그
////            let user = try JSONDecoder().decode(User.self, from: data)
////            completion(user)
////        } catch {
////            print("❌ 디코딩 실패1111111: \(error.localizedDescription)")
////            if let rawString = String(data: data, encoding: .utf8) {
////                print("⚠️ 응답 원문: \(rawString)")
////            }
////        }
////    }.resume()
////}
////
////
////
////
////    // MARK: - Kakao 로그인
////    func handleKakaoLogin() {
////        if (UserApi.isKakaoTalkLoginAvailable()) {
////            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
////                processKakaoLoginResult(token: oauthToken, error: error)
////            }
////        } else {
////            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
////                processKakaoLoginResult(token: oauthToken, error: error)
////            }
////        }
////    }
////
////    func processKakaoLoginResult(token: OAuthToken?, error: Error?) {
////        if let error = error {
////            print("❌ 카카오 로그인 실패: \(error.localizedDescription)")
////            return
////        }
////
////        guard let accessToken = token?.accessToken else {
////            print("❌ accessToken 없음")
////            return
////        }
////
////        print("✅ 카카오 로그인 성공 → AccessToken: \(accessToken)")
////        sendTokenToBackend(accessToken: accessToken)
////
////        UserApi.shared.me { (user, error) in
////            if let error = error {
////                print("❌ 사용자 정보 조회 실패: \(error.localizedDescription)")
////                return
////            }
////
////            let name = user?.kakaoAccount?.profile?.nickname ?? "이름 없음"
////            let providerId = "\(user?.id ?? 0)"
////            let body = [
////                "provider": "kakao",
////                "providerId": providerId,
////                "name": name
////            ]
////            
////            
////            postToServerLoginEndpoint(body: body) { user in
////                navigateToMain(user: user) // ✅ 서버에서 받은 User(id, name 등)로 이동
////            }
////        }
////    }
////
////    func sendTokenToBackend(accessToken: String) {
////        guard let url = URL(string: "https://your-server.com/api/auth/kakao") else { return }
////
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
////
////        URLSession.shared.dataTask(with: request) { data, response, error in
////            if let error = error {
////                print("❌ 서버 전송 실패: \(error.localizedDescription)")
////                return
////            }
////
////            if let httpResponse = response as? HTTPURLResponse {
////                print("📡 서버 응답 코드: \(httpResponse.statusCode)")
////            }
////        }.resume()
////    }
//
//    // MARK: - 화면 전환
//func navigateToMain(user: User) {
//    DispatchQueue.main.async {
//        let mainView = MainScreenView(user: user)
//        let mainVC = UIHostingController(rootView: mainView)
//
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first {
//            window.rootViewController = mainVC
//            window.makeKeyAndVisible()
//        } else {
//            print("❌ 윈도우 전환 실패: UIWindowScene을 찾을 수 없습니다.")
//        }
//    }
//}
//
////    func navigateToMain(user: User) {
////        let mainView = MainScreenView(user: user)
////        let mainVC = UIHostingController(rootView: mainView)
////
////        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////           let window = windowScene.windows.first {
////            window.rootViewController = mainVC
////            window.makeKeyAndVisible()
////        }
////    }
//
//    
//    
//

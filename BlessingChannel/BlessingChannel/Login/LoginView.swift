import Foundation
import SwiftUI
import GoogleSignIn
//import GoogleSignInSwift
import AuthenticationServices
import KakaoSDKUser
import KakaoSDKAuth
import NaverThirdPartyLogin


struct LoginView: View {
    private let naverDelegate = NaverLoginDelegate() // ✅ 그냥 속성으로 유지 (retain만 목적이면 충분)

    // MARK: - Naver (미구현)
    func handleNaverLogin() {
        guard let instance = NaverThirdPartyLoginConnection.getSharedInstance() else { return }
           instance.delegate = naverDelegate
           instance.requestThirdPartyLogin()
    }

    var body: some View {
        ZStack {
            Color(hex: "#FFF5BC").ignoresSafeArea()

            VStack(spacing: 20) {
                Text("로그인")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#6B3E26"))

                CustomLoginButton(title: "구글 로그인", action: handleGoogleSignIn)
                CustomLoginButton(title: "카카오 로그인", action: handleKakaoLogin)
                CustomLoginButton(title: "네이버 로그인", action: handleNaverLogin)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            handleAppleLogin(authResults: authorization) // ✅ 이 부분이 핵심
                        case .failure(let error):
                            print("❌ Apple 로그인 실패: \(error.localizedDescription)")
                        }
                    }
                )

                .signInWithAppleButtonStyle(.black)
                .frame(height: 45)
                .cornerRadius(10)
                .padding(.top, 10)
            }
            .padding()
        }
        Button(action: {
            let guestUser = User(name: "게스트", isGuest: true)
            navigateToMain(user: guestUser)
        }) {
            Text("그냥 한번 둘러볼래요")
                .foregroundColor(.gray)
                .font(.subheadline)
                .underline()
                .padding(.top, 20)
        }

    }
    // MARK: - Apple 로그인 처리
        func handleAppleLogin(authResults: ASAuthorization) {
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                let name = credential.fullName?.givenName ?? "이름 없음"
                let email = credential.email ?? "이메일 없음"

                print("✅ 애플 로그인 성공 → \(name), \(email)")

                // 필요한 경우 서버 전송 로직 추가 가능
                // sendAppleTokenToBackend(credential)

                navigateToMain(user: User(name: name, isGuest: false))
            }
        }

    // MARK: - Google 로그인
    func handleGoogleSignIn() {
        let config = GIDConfiguration(clientID: "314078962985-bcg7vno6uenkgcskqh1251ts9u7ene8s.apps.googleusercontent.com")

        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else {
            print("❌ rootViewController 가져오기 실패")
            return
        }

        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
            if let error = error {
                print("❌ 구글 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let user = user else {
                print("❌ 로그인 결과 없음")
                return
            }

            let name = user.profile?.name ?? "이름 없음"
            let email = user.profile?.email ?? "이메일 없음"
            print("✅ 구글 로그인 성공 → \(name), \(email)")

            navigateToMain(user: User(name: name, isGuest: false))
        }
    }

//        guard let rootVC = UIApplication.shared.connectedScenes
//            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else { return }
//
//        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
//            if let error = error {
//                print("❌ 구글 로그인 실패: \(error.localizedDescription)")
//                return
//            }
//
//            guard let profile = result?.user.profile else {
//                print("❌ 사용자 프로필 정보 없음")
//                return
//            }
//
//            let name = profile.name ?? "이름 없음"
//            let email = profile.email ?? "이메일 없음"
//            print("✅ 구글 로그인 성공 → \(name), \(email)")
//
//            navigateToMain(user: User(name: name))
//        }
    }

    // MARK: - Kakao 로그인
    func handleKakaoLogin() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                processKakaoLoginResult(token: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                processKakaoLoginResult(token: oauthToken, error: error)
            }
        }
    }

    func processKakaoLoginResult(token: OAuthToken?, error: Error?) {
        if let error = error {
            print("❌ 카카오 로그인 실패: \(error.localizedDescription)")
            return
        }

        guard let accessToken = token?.accessToken else {
            print("❌ accessToken 없음")
            return
        }

        print("✅ 카카오 로그인 성공 → AccessToken: \(accessToken)")
        sendTokenToBackend(accessToken: accessToken)

        UserApi.shared.me { (user, error) in
            if let error = error {
                print("❌ 사용자 정보 조회 실패: \(error.localizedDescription)")
                return
            }

            let name = user?.kakaoAccount?.profile?.nickname ?? "이름 없음"
            let email = user?.kakaoAccount?.email ?? "이메일 없음"
            navigateToMain(user: User(name: name, isGuest: false))
        }
    }

    func sendTokenToBackend(accessToken: String) {
        guard let url = URL(string: "https://your-server.com/api/auth/kakao") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 전송 실패: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 서버 응답 코드: \(httpResponse.statusCode)")
            }
        }.resume()
    }

    // MARK: - 화면 전환
    func navigateToMain(user: User) {
        let mainView = MainScreenView(user: user)
        let mainVC = UIHostingController(rootView: mainView)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }

    
    


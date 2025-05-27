import Foundation
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import KakaoSDKUser
import KakaoSDKAuth

struct LoginView: View {
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
                        case .success(let authResults):
                            print("✅ 애플 로그인 성공: \(authResults)")
                        case .failure(let error):
                            print("❌ 애플 로그인 실패: \(error.localizedDescription)")
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
    }

    // MARK: - Google 로그인
    func handleGoogleSignIn() {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("❌ 구글 로그인 실패: \(error.localizedDescription)")
                return
            }

            guard let profile = result?.user.profile else {
                print("❌ 사용자 프로필 정보 없음")
                return
            }

            let name = profile.name ?? "이름 없음"
            let email = profile.email ?? "이메일 없음"
            print("✅ 구글 로그인 성공 → \(name), \(email)")

            navigateToMain(user: User(name: name))
        }
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
            navigateToMain(user: User(name: name))
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

    // MARK: - Naver (미구현)
    func handleNaverLogin() {
        print("🟢 네이버 로그인 실행 (TODO)")
    }
}

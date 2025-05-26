//
//  LoginView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/25/25.
//

import Foundation

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

import AuthenticationServices // ✅ Apple 로그인용

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

                // ✅ 애플 로그인 버튼 (공식 스타일 사용)
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

    // MARK: - 로그인 핸들러

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

            // ✅ 메인 화면으로 전환
            let mainView = MainScreenView(user: User(name: name))
            let mainVC = UIHostingController(rootView: mainView)

            // 안전하게 window를 다시 찾아서 설정
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = mainVC
                window.makeKeyAndVisible()
            }
        }
    }


    func handleKakaoLogin() {
        print("🟡 카카오 로그인 실행")
        // TODO: Kakao SDK 연동
    }

    func handleNaverLogin() {
        print("🟢 네이버 로그인 실행")
        // TODO: Naver SDK 연동
    }
}


struct LoginButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(Color(hex: "#6B3E26"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFEB85"))
                .cornerRadius(8)
                .shadow(radius: 2)
        }
        .frame(width: 250)
    }
}


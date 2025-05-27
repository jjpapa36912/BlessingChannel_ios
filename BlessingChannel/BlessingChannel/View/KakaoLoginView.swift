//
//  KakaoLoginView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/27/25.
//

import Foundation
import SwiftUI
import KakaoSDKUser
import KakaoSDKAuth

struct KakaoLoginView: View {
    var body: some View {
        Button("카카오 로그인") {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                // ✅ 카카오톡 앱으로 로그인
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        print("❌ 로그인 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ 로그인 성공 (토큰): \(oauthToken?.accessToken ?? "")")
                        fetchUserInfo()
                    }
                }
            } else {
                // ✅ 웹 계정 로그인 (카카오톡 미설치)
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        print("❌ 로그인 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ 로그인 성공 (토큰): \(oauthToken?.accessToken ?? "")")
                        fetchUserInfo()
                    }
                }
            }
        }
        .padding()
    }

    func fetchUserInfo() {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("❌ 사용자 정보 조회 실패: \(error.localizedDescription)")
            } else {
                if let nickname = user?.kakaoAccount?.profile?.nickname {
                    print("👤 사용자 닉네임: \(nickname)")
                }
                if let email = user?.kakaoAccount?.email {
                    print("📧 사용자 이메일: \(email)")
                }
            }
        }
    }
}

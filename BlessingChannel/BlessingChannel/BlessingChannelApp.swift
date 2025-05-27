//
//  BlessingChannelApp.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/25/25.
//

import Foundation
import SwiftUI
import KakaoSDKAuth

@main
struct BlessingChannelApp: App {
    // AppDelegate 연동
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LoginView()
                .onOpenURL { url in
                    // ✅ Kakao 로그인 URL 처리
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

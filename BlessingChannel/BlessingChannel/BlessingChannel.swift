//
//  BlessingChannelApp.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/25/25.
//

import Foundation
import SwiftUI
import KakaoSDKAuth
import NaverThirdPartyLogin // ✅ 네이버 SDK 임포트 추가


@main
struct BlessingChannel: App {
    // AppDelegate 연동
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
            WindowGroup {
                LoginView()
                    .onOpenURL { url in
                        // ✅ Kakao 로그인 처리
                        if AuthApi.isKakaoTalkLoginUrl(url) {
                            _ = AuthController.handleOpenUrl(url: url)
                        }

                        // ✅ Naver 로그인 처리
                        // ✅ Naver 로그인 처리 (URL 판단 없이 바로 시도)
                                            _ = NaverThirdPartyLoginConnection
                                                .getSharedInstance()
                                                .receiveAccessToken(url)
                    }
            }
        }
}

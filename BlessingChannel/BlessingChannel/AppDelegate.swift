//
//  AppDelegate.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//


import Foundation
import UIKit
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

class AppDelegate: NSObject, UIApplicationDelegate {

    // ✅ 앱이 외부 URL을 열 때 Kakao 또는 Google 로그인 처리
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // ✅ Kakao 로그인 핸들링
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        // ✅ Google 로그인 핸들링
        return GIDSignIn.sharedInstance.handle(url)
    }

    // ✅ 앱 시작 시 Kakao SDK 초기화
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        KakaoSDK.initSDK(appKey: "64eb2c6693e4feffd396d4f51eaa6590") // ← 네이티브 앱 키로 교체
        return true
    }
}


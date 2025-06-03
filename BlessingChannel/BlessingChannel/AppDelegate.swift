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
import NaverThirdPartyLogin
import KakaoSDKAuth
import NaverThirdPartyLogin
import GoogleMobileAds


class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - 앱 시작 시 초기화
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // ✅ Kakao 초기화
        KakaoSDK.initSDK(appKey: "64eb2c6693e4feffd396d4f51eaa6590")

        // ✅ Naver 초기화
        let naver = NaverThirdPartyLoginConnection.getSharedInstance()
        naver?.isNaverAppOauthEnable = true
        naver?.isInAppOauthEnable = true
        naver?.isOnlyPortraitSupportedInIphone()
        naver?.serviceUrlScheme = "com.blessing.channel"
        naver?.consumerKey = "loHCwroBGxHcKCmHERN2"
        naver?.consumerSecret = "Sv1_xuZpwx"
        naver?.appName = "BlessingChannel"

        // ✅ GoogleMobileAds 초기화
        MobileAds.shared.start(completionHandler: nil)

        return true
    }
    
    // MARK: - 소셜 로그인 URL 처리
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // ✅ Kakao 로그인 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        // ✅ Naver 로그인 처리
        _ = NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)

        // ✅ Google 로그인 처리
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }

        return false
    }
}


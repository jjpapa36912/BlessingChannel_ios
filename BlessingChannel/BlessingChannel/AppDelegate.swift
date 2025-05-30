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

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Kakao 로그인
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        // ✅ Naver 로그인
        NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)


        // Google 로그인
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Kakao 초기화
        KakaoSDK.initSDK(appKey: "64eb2c6693e4feffd396d4f51eaa6590")

        // Naver 초기화
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone() // ✅ 함수 호출로 수정
        instance?.serviceUrlScheme = "com.blessing.channel.BlessingChannel"
        instance?.consumerKey = "loHCwroBGxHcKCmHERN2"
        instance?.consumerSecret = "Sv1_xuZpwx"
        instance?.appName = "BlessingChannel"

        return true
    }
}


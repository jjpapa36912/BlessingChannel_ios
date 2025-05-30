//
//  NaverLoginDelegate.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/30/25.
//

import Foundation

import NaverThirdPartyLogin

class NaverLoginDelegate: NSObject, NaverThirdPartyLoginConnectionDelegate {
    // ✅ 로그인 성공 (최초 인증 코드 → Access Token 발급)
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        if let token = NaverThirdPartyLoginConnection.getSharedInstance()?.accessToken {
            print("✅ Naver 토큰 발급 성공: \(token)")
            // TODO: 서버 전송 or 사용자 정보 요청
        } else {
            print("❌ Naver 토큰 없음")
        }
    }

    // ✅ 로그인 실패
    func oauth20Connection(_ connection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("❌ Naver 로그인 실패: \(error.localizedDescription)")
    }

    // ✅ 토큰 삭제 완료 시 호출
    func oauth20ConnectionDidFinishDeleteToken() {
        print("✅ Naver 토큰 삭제 완료")
    }

    // ✅ 토큰 리프레시 성공 시 호출
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("🔄 Naver 토큰 리프레시 완료")
    }
}

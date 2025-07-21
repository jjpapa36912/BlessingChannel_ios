////
////  NaverLoginDelegate.swift
////  BlessingChannel
////
////  Created by 김동준 on 5/30/25.
////
//
//import Foundation
//
//import NaverThirdPartyLogin
//import SwiftUI
//
//class NaverLoginDelegate: NSObject, NaverThirdPartyLoginConnectionDelegate {
//    // ✅ 로그인 성공 (최초 인증 코드 → Access Token 발급)
//    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
//        if let token = NaverThirdPartyLoginConnection.getSharedInstance()?.accessToken {
//            print("✅ Naver 토큰 발급 성공: \(token)")
//            // TODO: 서버 전송 or 사용자 정보 요청
//            fetchUserInfo(accessToken: token)
//        } else {
//            print("❌ Naver 토큰 없음")
//        }
//    }
//    
////    // ✅ 사용자 정보 요청
////       private func fetchUserInfo(accessToken: String) {
////           guard let url = URL(string: "https://openapi.naver.com/v1/nid/me") else { return }
////
////           var request = URLRequest(url: url)
////           request.httpMethod = "GET"
////           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
////
////           URLSession.shared.dataTask(with: request) { data, response, error in
////               if let error = error {
////                   print("❌ 사용자 정보 요청 실패: \(error.localizedDescription)")
////                   return
////               }
////
////               guard let data = data else {
////                   print("❌ 응답 데이터 없음")
////                   return
////               }
////
////               do {
////                   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
////                   print("📦 네이버 응답 전체: \(json ?? [:])") // ✅ 전체 출력 추가
////
////                   if let response = json?["response"] as? [String: Any] {
////                       let rawName = response["name"] as? String ?? ""
////                       let nickname = response["nickname"] as? String
////                       let name = nickname?.removingPercentEncoding ?? rawName.removingPercentEncoding ?? "이름 없음"
////                       
////                       let providerId = String(describing: response["id"] ?? "")
////
////                       print("✅ [NAVER] 사용자 이름: \(name)")
////                       print("✅ [NAVER] providerId: \(providerId)")
////
////                       let body: [String: Any] = [
////                           "provider": "naver",
////                           "providerId": providerId,
////                           "name": name
////                       ]
////
////                       postToServerLoginEndpoint(body: body) { user in
////                           DispatchQueue.main.async {
////                               self.navigateToMain(user: user) // ✅ 서버에서 내려준 진짜 User(id: Long, name: String ...)
////                           }
////                       }
////
////                       print("✅ [NAVER] 사용자 이름: \(name)")
////                       
////                   } else {
////                       print("❌ JSON 파싱 실패: 'response' 키 없음")
////                   }
////               } catch {
////                   print("❌ JSON 디코딩 에러: \(error.localizedDescription)")
////               }
////           }.resume()
////       }
//
//
////    // ✅ 로그인 실패
////    func oauth20Connection(_ connection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
////        print("❌ Naver 로그인 실패: \(error.localizedDescription)")
////    }
////
////    // ✅ 토큰 삭제 완료 시 호출
////    func oauth20ConnectionDidFinishDeleteToken() {
////        print("✅ Naver 토큰 삭제 완료")
////    }
////
////    // ✅ 토큰 리프레시 성공 시 호출
////    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
////        print("🔄 Naver 토큰 리프레시 완료")
////        if let token = NaverThirdPartyLoginConnection.getSharedInstance()?.accessToken {
////                print("🔐 리프레시된 accessToken: \(token)")
////                fetchUserInfo(accessToken: token) // ✅ 여기에 추가해야 화면이 바뀜
////            } else {
////                print("❌ 리프레시 후 accessToken 없음")
////            }
////    }
//    // ✅ 메인화면 이동
//        private func navigateToMain(user: User) {
//            let mainView = MainScreenView()
//            let mainVC = UIHostingController(rootView: mainView)
//
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let window = windowScene.windows.first {
//                window.rootViewController = mainVC
//                window.makeKeyAndVisible()
//            }
//        }
//}

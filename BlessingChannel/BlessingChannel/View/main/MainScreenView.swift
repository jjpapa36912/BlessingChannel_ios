//
//  MainScreenView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//

import Foundation
import SwiftUI
import GoogleSignIn

struct MainScreenView: View {
    let user: User
    @State private var totalDonation = 0           // 🔥 전체 유저 합산 금액
    @State private var userDonation = 0
    @State private var showMenu = false
    @StateObject private var adManager = RewardedAdManager()

    var body: some View {
       
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    // 상단바
                    HStack {
                        Button(action: { withAnimation { showMenu.toggle() } }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.brown)
                        }
                        Spacer()
                        Text("\(user.name)님 환영합니다")
                            .fontWeight(.bold)
                        Spacer()
                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.4))
                    
                    // 진행률 표시
                    DonationProgressView(current: totalDonation, goal: 1_000_000)
                    
                    // 프로필
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.brown)
                        Text(user.name)
                            .font(.title3)
                            .foregroundColor(.brown)
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding()
                    
                    // 광고 보고 기부하기 버튼
                    Button("광고 보고 기부 하기") {
                        if !canWatchRewardedAd() {
                            print("❗ 오늘 보상형 광고 시청 횟수 초과 (최대 5회)")
                            return
                        }
                        
                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                            adManager.showAd(from: rootVC) {
                                recordRewardedAdWatched()
                                reportRewardedAdWatched()
                            }
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    
                    
                    // 광고 로드 상태 표시
                    if !adManager.isAdLoaded {
                        ProgressView("광고 로딩 중...")
                            .onAppear { adManager.loadAd() }
                    }
                    
                    // 배너 광고 영역
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(0..<4) { _ in
                                BannerAdView()
                                    .frame(height: 50)
                                    .cornerRadius(8)
                            }
                            
                            Text("필요한 정보는 당신에게, 따뜻한 나눔은 아이들에게.")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                                .foregroundColor(.brown)
                        }
                        .padding()
                    }
                    .onAppear {
                        
                        //                        if !hasReportedToday() {
                        //                            onEnterMain()                    // ✅ 배너 4원 + 0.4P 적립
                        //                            markReportedToday()             // ✅ 날짜 저장
                        //                        } else {
                        //                            print("🔁 오늘 이미 배너 수익 처리됨")
                        //                        }
                        registerAndFetchSummary(userId: user.name)
                        
                        //                    fetchTotalDonation() // 이건 서버 전체 모금액
                        //                    fetchSummaryAndRegisterIfNeeded(userId: user.name) // 유저 등록 + 요약 정보 받기
                        
                        reportBannerViewAndFetchDonations()
                        
                        
                    }
                    
                    //                NavigationBarView()
                    Button(action: {
                        let boardView = BoardScreenView(currentUser: user.name)
                        let vc = UIHostingController(rootView: boardView)
                        vc.modalPresentationStyle = .fullScreen  // ✅ 전체 화면으로 설정
                        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
                    }) {
                        Text("📋 게시판")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)



                    
                    
                }
                
                // 🟡 햄버거 메뉴 레이어
                if showMenu {
                    VStack(alignment: .leading, spacing: 16) {
                        Button("마이페이지") {
                            let myPageView = MyPageView(user: user)
                            let vc = UIHostingController(rootView: myPageView)
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
                            print("마이페이지 이동") }
                        Button("모금 사용처") { print("모금 사용처 이동") }
                        Button("로그아웃") {
                            GIDSignIn.sharedInstance.signOut()
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.top, 60)
                    .padding(.leading, 8)
                    .transition(.move(edge: .leading))
                }
            }
        }
   
    func canReportBannerToday() -> Bool {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "bannerReported_\(user.name)_\(today)"
        return !UserDefaults.standard.bool(forKey: key)
    }

    func markBannerReportedToday() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "bannerReported_\(user.name)_\(today)"
        UserDefaults.standard.set(true, forKey: key)
    }

    func canWatchRewardedAd() -> Bool {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "rewardedAdCount_\(today)"
        let count = UserDefaults.standard.integer(forKey: key)
        return count < 5
    }
    
    func registerAndFetchSummary(userId: String) {
        guard let url = URL(string: "\(API.baseURL)/api/users/summary") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["userId": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 유저 등록/요약 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let donation = json["totalDonation"] as? Int,
                  let point = json["totalPoint"] as? Int else {
                print("❌ 응답 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.totalDonation = donation
                self.userDonation = point
                print("✅ 유저 등록/기부 반영 완료: 총 \(donation)P / 내 포인트 \(point)P")
            }
        }.resume()
    }


    func recordRewardedAdWatched() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "rewardedAdCount_\(today)"
        let count = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(count + 1, forKey: key)
    }

    func onEnterMain() {
        guard canReportBannerToday() else {
            print("⚠️ 오늘은 이미 배너 수익 보고됨")
            return
        }

        let url = URL(string: "\(API.baseURL)/api/users/\(user.name)/reward?amount=4&adType=banner")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        URLSession.shared.dataTask(with: req) { _, _, _ in
            print("✅ 배너 기부 및 포인트 적립 완료")
            markBannerReportedToday()

            fetchTotalDonation()
            fetchSummaryAndRegisterIfNeeded(userId: user.name)
        }.resume()
    }

    
    func reportRewardedAdWatched() {
        guard let url = URL(string: "\(API.baseURL)/api/users/\(user.name)/reward?amount=20&adType=rewarded") else {
            print("❌ 보상형 광고 서버 URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("❌ 보상형 광고 보고 실패: \(error.localizedDescription)")
                return
            }
            print("✅ 보상형 광고 수익 보고 완료 (30원 + 3P)")
            fetchTotalDonation()
            fetchSummaryAndRegisterIfNeeded(userId: user.name)
        }.resume()
    }


    func reportBannerViewAndFetchDonations() {
        guard let url = URL(string: "\(API.baseURL)/api/ads/report?section=main&userId=\(user.name)") else {
            print("❌ 배너 이벤트 URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ 광고 보고 기록 전송 실패: \(error.localizedDescription)")
                return
            }

            print("✅ 광고 노출 보고 성공 → 기부 및 포인트 적립 완료됨")
            fetchSummaryAndRegisterIfNeeded(userId: user.name)
            fetchTotalDonation()
        }.resume()
    }

    
    func fetchSummaryAndRegisterIfNeeded(userId: String) {
        guard let url = URL(string: "\(API.baseURL)/api/users/\(userId)/summary") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["point": 0], options: [])

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ 요약 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let donation = json["totalDonation"] as? Int else {
                print("❌ 응답 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.userDonation = donation
                print("✅ 유저 등록 및 요약 수신 완료: \(donation)P")
            }
        }.resume()
    }

    
    func registerUser(userId: String) {
        guard let url = URL(string: "\(API.baseURL)/api/users/\(userId)/summary") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["point": 0], options: [])

        URLSession.shared.dataTask(with: request) { _, _, _ in
            print("✅ 유저 등록 완료 → 요약 정보 요청")
            fetchSummary(userId: userId)
        }.resume()
    }

    func fetchSummary(userId: String) {
        guard let url = URL(string: "\(API.baseURL)/api/users/name/\(userId)/summary") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let donation = json["totalDonation"] as? Int else {
                print("❌ 요약 정보 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.totalDonation = donation
                print("✅ 요약 정보 수신 완료: \(donation)P")
            }
        }.resume()
    }

    func hasReportedToday() -> Bool {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        return UserDefaults.standard.string(forKey: "bannerReportedDate") == today
    }

    func markReportedToday() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        UserDefaults.standard.set(today, forKey: "bannerReportedDate")
    }


    func fetchTotalDonation() {
        guard let url = URL(string: "\(API.baseURL)/api/users/total-donation") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 요청 실패: \(error.localizedDescription)")

                if let nsError = error as NSError? {
                    print("📛 에러 코드: \(nsError.code)")
                    print("📛 도메인: \(nsError.domain)")

                    switch nsError.code {
                    case NSURLErrorTimedOut:
                        print("⏱ 서버 응답 시간 초과")
                    case NSURLErrorNotConnectedToInternet:
                        print("📡 인터넷 연결 안 됨")
                    case NSURLErrorCannotFindHost:
                        print("🌐 서버 호스트를 찾을 수 없음")
                    case NSURLErrorCannotConnectToHost:
                        print("🚫 서버에 연결할 수 없음")
                    default:
                        print("❓ 기타 네트워크 오류 발생")
                    }
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ HTTP 상태 코드: \(httpResponse.statusCode)")
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let total = json["totalDonation"] as? Int else {
                print("❌ 응답 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.totalDonation = total
                print("✅ 총 기부액 수신 완료: \(total)P")
            }
        }.resume()
    }


}

//struct API {
////    static let baseURL = "http://3.36.86.32:8080"
////    static let baseURL = "http://192.0.0.2:8080"
//    static let baseURL = "http://127.0.0.1:8080"
//}
struct API {
    static let baseURL: String = {
        #if DEBUG
        return "http://127.0.0.1:8080"  // 🔧 개발용 로컬 서버
        #else
        return "http://3.36.86.32:8080" // 🚀 운영 서버 (예: AWS)
        #endif
    }()
}



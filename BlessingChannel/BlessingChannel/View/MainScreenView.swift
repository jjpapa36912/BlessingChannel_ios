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
    @State private var totalDonation = 0
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
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        adManager.showAd(from: rootVC) {
                            totalDonation += 10
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

                        Text("광고 한 편, 당신에게 유익함을,\n아이들에게는 따뜻함을 전합니다.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .foregroundColor(.brown)
                    }
                    .padding()
                }
                .onAppear {
                    fetchTotalDonation()
                    fetchTotalDonation() // 이건 서버 전체 모금액
                    registerUserAndFetchSummary(userId: user.name) // 🔥 개인 요약 정보 조회 (totalDonation 세팅)

                }

                NavigationBarView()
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
    
    func registerUserAndFetchSummary(userId: String) {
        guard let url = URL(string: "\(API.baseURL)/api/users/\(userId)/summary") else { return }

        // 🔸 유저 등록 (POST)
        var registerRequest = URLRequest(url: url)
        registerRequest.httpMethod = "POST"
        registerRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registerRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["point": 0], options: [])

        URLSession.shared.dataTask(with: registerRequest) { _, _, _ in
            // 🔸 등록 후 요약 정보 조회 (GET)
            var summaryRequest = URLRequest(url: URL(string: "\(API.baseURL)/api/users/name/\(userId)/summary")!)
            summaryRequest.httpMethod = "GET"

            URLSession.shared.dataTask(with: summaryRequest) { data, _, error in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let donation = json["totalDonation"] as? Int else {
                    print("❌ 요약 정보 파싱 실패")
                    return
                }

                DispatchQueue.main.async {
                    self.totalDonation = donation
                }
            }.resume()
        }.resume()
    }


    func fetchTotalDonation() {
        guard let url = URL(string: "\(API.baseURL)/api/ads/total") else {
            print("❌ URL 생성 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 서버 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let total = json["totalDonation"] as? Int else {
                print("❌ 응답 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.totalDonation = total
            }
        }.resume()
    }
}

struct API {
//    static let baseURL = "http://3.36.86.32:8080"
    static let baseURL = "http://192.0.0.2:8080"
}


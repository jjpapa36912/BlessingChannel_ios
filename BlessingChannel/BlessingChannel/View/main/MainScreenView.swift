import SwiftUI
import GoogleSignIn

struct MainScreenView: View {
    let user: User
    @State private var totalDonation = 0
    @State private var userDonation = 0
    @State private var showMenu = false
    @StateObject private var adManager = RewardedAdManager()
    @State private var showBoard = false
    @State private var showReservationHelper = false
    @State private var showYouTubeHelper = false
    @State private var showCoupangHelper = false
    @State private var showKakaoHelper = false





    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                
                // ✅ 알림 문구 삽입
//                    Text("""
//                    ※ 광고 수익은 운영비를 제외하고 모두 기부에 사용됩니다.
//                    """)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                    .padding(.top, 8)
                
                
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

                DonationProgressView(current: self.totalDonation , goal: 1_000_000)

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

                
                
                
                // 기존 광고 버튼 및 ScrollView 영역 주석 처리 대신:
                GeometryReader { geometry in
                    VStack {
                        Spacer().frame(height: 30)

                        Text("광고를 준비 중입니다.")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding()

                        Spacer()
                            .frame(height: geometry.size.height * 0.3)  // 화면 높이의 30%를 빈 공간으로 확보
                    }
                    .frame(maxWidth: .infinity)
                }


//                Button("정보 보고 기부에 참여하기") {
//                    if !canWatchRewardedAd() {
//                        print("❗ 오늘 보상형 광고 시청 횟수 초과 (최대 15회)")
//                        return
//                    }
//                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
//                        adManager.showAd(from: rootVC) {
//                            recordRewardedAdWatched()
//                            reportRewardedAdWatched()
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.brown)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .padding(.horizontal)
//
//                if !adManager.isAdLoaded {
//                    ProgressView("광고 로딩 중...")
//                        .onAppear { adManager.loadAd() }
//                }
//
//                ScrollView {
//                    VStack(spacing: 10) {
//                        ForEach(0..<4) { _ in
//                            BannerAdView()
//                                .frame(height: 50)
//                                .cornerRadius(8)
//                        }
//
//                        Text("필요한 정보는 당신에게, 따뜻한 나눔은 아이들에게.")
//                            .font(.footnote)
//                            .multilineTextAlignment(.center)
//                            .padding(.top, 10)
//                            .foregroundColor(.brown)
//                    }
//                    .padding()
//                }
//                .onAppear {
//                    if !user.isGuest {
//                            registerAndFetchSummary(userId: user.name)
//                            reportBannerViewAndFetchDonations()
//                        } else {
//                            print("👤 게스트로 진입 — 유저 요약 등록/포인트 적립 생략")
//                        }
//
//                        fetchTotalDonation()  // ✅ 이건 무조건 실행
//                }
                
                // 네이버 예약 버튼
                // 네이버 예약 버튼
                Button("🗣️ 네이버 예약하기") {
                    withAnimation {
                        showReservationHelper = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // ✅ 여백 추가
                .padding(.top, 8)

                Button("🎬 유튜브 검색하기") {
                    withAnimation {
                        showYouTubeHelper = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                Button("🛒 쿠팡 검색하기") {
                    withAnimation {
                        showCoupangHelper = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                Button("💬 카카오톡 메시지 보내기") {
                    withAnimation {
                        showKakaoHelper = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                Button("게시판") {
                    print("📋 게시판 버튼 클릭됨")
                    showBoard = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
                .fullScreenCover(isPresented: $showBoard) {
                    BoardMainView(user: user)
                }


            }
            // ✅ 네이버 예약 오버레이 뷰
               if showReservationHelper {
                   Color.black.opacity(0.001)
                       .ignoresSafeArea()
                       .onTapGesture {
                           withAnimation {
                               showReservationHelper = false
                           }
                       }

                   VStack {
                       ReservationHelperView(showReservationHelper: $showReservationHelper)
                           .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
                           .background(Color.white)
                           .cornerRadius(20)
                           .shadow(radius: 10)
                           .padding()
                   }
                   .transition(.move(edge: .bottom))
               }
            
            // 유튜브 검색
            if showYouTubeHelper {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showYouTubeHelper = false
                        }
                    }

                VStack {
                    YouTubeHelperView(showYouTubeHelper: $showYouTubeHelper)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                }
                .transition(.move(edge: .bottom))
            }

                //쿠팡 검색
            if showCoupangHelper {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showCoupangHelper = false
                        }
                    }

                VStack {
                    CoupangHelperView(showCoupangHelper: $showCoupangHelper)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                }
                .transition(.move(edge: .bottom))
            }
            // 카카오톡 메세지 보내기
            if showKakaoHelper {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showKakaoHelper = false
                        }
                    }

                VStack {
                    KakaoHelperView(showKakaoHelper: $showKakaoHelper)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                }
                .transition(.move(edge: .bottom))
            }

            // 1. 먼저 배경 클릭 감지용 뷰를 추가 (메뉴 아래에 위치해야 메뉴가 보임)
                if showMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showMenu = false
                            }
                        }
                }
            
            if showMenu {
                VStack(alignment: .leading, spacing: 16) {
                    if user.isGuest {
                        Button("로그인") {
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
                        }
                    } else {
                        Button("마이페이지") {
                            let myPageView = MyPageView(user: user)
                            let vc = UIHostingController(rootView: myPageView)
                            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
                        }
//                        Button("모금 사용처") { print("모금 사용처 이동") }
                        Button("로그아웃") {
                            GIDSignIn.sharedInstance.signOut()
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
                        }
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
        .fullScreenCover(isPresented: $showBoard) {
            BoardMainView(user: user)
        }
    }

    func fetchTotalDonation() {
        guard let url = URL(string: "\(API.baseURL)/api/users/total-donation") else {
            print("❌ 전체 기부액 URL 생성 실패")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ 전체 기부액 요청 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let total = json["totalDonation"] as? Int else {
                print("❌ 전체 기부액 응답 파싱 실패")
                return
            }

            DispatchQueue.main.async {
                self.totalDonation = total
                print("✅ 전체 기부액 수신: \(total)")
            }
        }.resume()
    }

    func canWatchRewardedAd() -> Bool {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "rewardedAdCount_\(today)"
        let count = UserDefaults.standard.integer(forKey: key)
        return count < 15
    }

    func recordRewardedAdWatched() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let key = "rewardedAdCount_\(today)"
        let count = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(count + 1, forKey: key)
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
                  let point = json["point"] as? Int else {
                print("❌ 응답 파싱 실패")
                return
            }
            DispatchQueue.main.async {
//                self.totalDonation = donation
                self.userDonation = point
                print("✅ 유저 등록/기부 반영 완료: 총 \(donation)P / 내 포인트 \(point)P")
            }
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
        }.resume()
    }
}

struct API {
    static let baseURL: String = {
        #if !DEBUG
        return "http://127.0.0.1:8080"
        #else
        return "http://3.36.86.32:8080"
        #endif
    }()
}

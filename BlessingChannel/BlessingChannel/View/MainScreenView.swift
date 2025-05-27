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

    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                Button(action: { showMenu.toggle() }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.brown)
                }
                Spacer()
                Text("\(user.name)님 환영합니다")
                    .fontWeight(.bold)
                Spacer()
                Spacer() // 오른쪽 여백용
            }
            .padding()
            .background(Color.yellow.opacity(0.4))

            // 드롭다운 메뉴
            if showMenu {
                VStack(alignment: .leading) {
                    Button("마이페이지") {
                        print("마이페이지 이동")
                    }
                    Button("모금 사용처") {
                        print("모금 사용처 이동")
                    }
                    Button("로그아웃") {
                        // 로그아웃 후 로그인 화면으로
                        GIDSignIn.sharedInstance.signOut()
                        UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.3))
            }

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

            // 광고 버튼
            Button("광고 보고 기부 하기") {
                print("보상형 광고 실행")
                // 여기서 광고 호출 및 서버 연동 로직 작성
                totalDonation += 10
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brown)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)

            // 광고 영역
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow.opacity(0.3))
                            .frame(height: 100)
                            .overlay(Text("광고 \(index + 1) 영역"))
                    }

                    Text("광고 한 편, 당신에게 유익함을,\n아이들에게는 따뜻함을 전합니다.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .foregroundColor(.brown)
                }
                .padding()
            }

            NavigationBarView()
        }
    }
}

//
//  MyPageView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/3/25.
//

import Foundation
import SwiftUI

struct MyPageView: View {
    let user: User
    @Environment(\.presentationMode) var presentationMode
    
    @State private var point: Int = 0
    @State private var donation: Int = 0
    @State private var redeemHistory: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // 🔹 상단바
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.brown)
                }
                Spacer()
                Text("마이페이지")
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                Spacer()
                Spacer()
            }
            .padding()
            .background(Color(hex: "#FFF4C2"))
            
            // 🔹 프로필 아이콘 및 이름
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.brown)
            Text("\(user.name)님의 마이페이지")
                .fontWeight(.bold)
                .foregroundColor(.brown)
            
            // 🔹 포인트 및 누적 수익
            Text("현재 포인트: \(point)P")
                .font(.subheadline)
                .foregroundColor(.black)
                
            
            // 🔹 쿠폰함 열기 버튼
            Button("쿠폰함 열기") {
                // TODO: 쿠폰함 이동 처리
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.brown)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // 🔹 랭킹 보드
            VStack(alignment: .leading, spacing: 4) {
                Text("🏆 랭킹 보드")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                ForEach(topUsers.indices, id: \.self) { idx in
                    let user = topUsers[idx]
                    Text("\(idx + 1)위 - \(user.name): \(user.point)P")
                }
            }
            .padding(.top)
            
            // 🔹 보상 버튼
            Button("보상 받기 (100P 차감)") {
                // TODO: 포인트 차감 및 보상 로직
            }
            .disabled(point < 100)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(point >= 100 ? Color(hex: "#FFF4C2") : Color.gray.opacity(0.3))
            .foregroundColor(.black)
            .cornerRadius(20)
            
            Divider().padding(.top)
            
            // 🔹 포인트 교환 이력
            VStack(alignment: .leading) {
                Text("📜 포인트 교환 이력")
                    .fontWeight(.bold)
                if redeemHistory.isEmpty {
                    Text("아직 교환 내역이 없습니다.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else {
                    ForEach(redeemHistory.reversed(), id: \.self) { entry in
                        Text("• \(entry)")
                            .font(.footnote)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 🔹 하단 내비게이션
            HStack {
                Spacer()
                Image(systemName: "house.fill")
                    .foregroundColor(.brown)
                Spacer()
                Image(systemName: "person.fill")
                    .foregroundColor(.brown)
                Spacer()
            }
            .padding()
            .background(Color(hex: "#FFE082"))
        }
        .background(Color(hex: "#FFF4C2").ignoresSafeArea())
        .onAppear {
            fetchUserSummary(userId: user.name) { p, d in
                self.point = p
                self.donation = d
            }
            fetchRedeemHistory(userId: user.name) { history in
                self.redeemHistory = history
            }
            fetchTopUsers() // 🔥 랭킹 보드 API 호출
        }
    }
    
    // MARK: - 서버 통신 메서드
    func fetchUserSummary(userId: String, completion: @escaping (Int, Int) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/api/users/name/\(userId)/summary") else { return }
        var req = URLRequest(url: url); req.httpMethod = "GET"
        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            let p = json["totalPoint"] as? Int ?? 0
            let d = json["totalDonation"] as? Int ?? 0
            DispatchQueue.main.async { completion(p, d) }
        }.resume()
    }
    
    func fetchRedeemHistory(userId: String, completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/reward/history?userId=\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String] else {
                return
            }
            DispatchQueue.main.async { completion(jsonArray) }
        }.resume()
    }
    
    @State private var topUsers: [RankedUser] = []

    func fetchTopUsers() {
        guard let url = URL(string: "\(API.baseURL)/api/users/rank/top3") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode([RankedUser].self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                self.topUsers = decoded
            }
        }.resume()
    }

}

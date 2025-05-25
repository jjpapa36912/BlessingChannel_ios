//
//  LoginView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/25/25.
//

import Foundation

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            Color(hex: "#FFF3C1").edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("로그인")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#6B3E26"))

                LoginButton(title: "구글 로그인") {
                    print("📍 구글 로그인 시도")
                }

                LoginButton(title: "카카오 로그인") {
                    print("📍 카카오 로그인 시도")
                }

                LoginButton(title: "네이버 로그인") {
                    print("📍 네이버 로그인 시도")
                }
            }
        }
    }
}

struct LoginButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(Color(hex: "#6B3E26"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFEB85"))
                .cornerRadius(8)
                .shadow(radius: 2)
        }
        .frame(width: 250)
    }
}


//
//  ReservationHelperView.swift
//  BlessingChannel
//
//  Created by 김동준 on 7/12/25.
//

import Foundation
import SwiftUI

struct ReservationHelperView: View {
    @Binding var showReservationHelper: Bool
    @State private var userQuery: String = ""
    @State private var bookingURL: String = ""
    @State private var parsedName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("← 뒤로가기") {
                    withAnimation {
                        showReservationHelper = false
                    }
                }
                .foregroundColor(.blue)
                Spacer()
                Text("🗣️ 음성 예약 도우미")
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        showReservationHelper = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            TextField("예: 세종 리즈헤어 예약하고 싶어", text: $userQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top)

            VStack(spacing: 10) {
                if isListening {
                    Text("🎙️ 인식 중: \(speechRecognizer.recognizedText)")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                HStack(spacing: 20) {
                    Button("🎤 음성 인식 시작") {
                        isListening = true
                        speechRecognizer.startRecording()
                    }
                    .disabled(isListening)

                    Button("🛑 종료") {
                        speechRecognizer.stopRecording()
                        userQuery = speechRecognizer.recognizedText
                        isListening = false
                    }
                    .disabled(!isListening)
                }
            }

            Button(action: {
                fetchReservationLink()
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("예약 링크 찾기")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(userQuery.isEmpty || isLoading)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let errorMessage = errorMessage {
                Text("❌ \(errorMessage)")
                    .foregroundColor(.red)
            }

            if !parsedName.isEmpty {
                VStack(spacing: 8) {
                    Text("🔍 추출된 예약 대상:")
                        .font(.subheadline)
                    Text(parsedName)
                        .font(.title3)
                        .bold()

                    Button("🔗 예약 페이지 열기") {
                        if let url = URL(string: bookingURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
    }

    func fetchReservationLink() {
        isLoading = true
        errorMessage = nil
        parsedName = ""
        bookingURL = ""

        let baseURL: String

        #if !DEBUG
        baseURL = "http://localhost:5001"
        #else
        baseURL = "http://3.36.86.32:5001" // 🔁 실제 운영 서버 주소로 교체
        #endif

        guard let encoded = userQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/getReservationLink?query=\(encoded)") else {
            errorMessage = "잘못된 요청입니다."
            isLoading = false
            return
        }


        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "네트워크 에러: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "데이터를 받지 못했습니다."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let name = json["parsed_name"] as? String,
                           let link = json["url"] as? String {
                            parsedName = name
                            bookingURL = link
                            // 자동으로 링크 열기
                            if let url = URL(string: link) {
                                UIApplication.shared.open(url)
                            }
                        } else if let err = json["error"] as? String {
                            errorMessage = "서버 오류: \(err)"
                        } else {
                            errorMessage = "응답 파싱 실패"
                        }
                    }
                } catch {
                    errorMessage = "JSON 디코딩 실패: \(error)"
                }
            }
        }.resume()
    }
}

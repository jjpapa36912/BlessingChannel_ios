//
//  KakaoHelperView.swift
//  BlessingChannel
//
//  Created by 김동준 on 7/12/25.
//

import Foundation
import SwiftUI
import Speech
import KakaoSDKTemplate
import KakaoSDKLink

struct KakaoHelperView: View {
    @Binding var showKakaoHelper: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    @State private var recognizedText: String = ""
    @State private var inputText: String = ""
    @State private var toName: String = ""
    @State private var finalMessage: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("← 뒤로가기") {
                    withAnimation {
                        showKakaoHelper = false
                    }
                }
                .foregroundColor(.blue)
                Spacer()
                Text("💬 카카오 메시지 보내기")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        showKakaoHelper = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("✍️ 자연어 명령 입력")
                    .font(.subheadline)
                TextField("예: 엄마에게 사랑해 라고 보내줘", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("🗣️ 인식된 음성:")
                    .font(.subheadline)
                Text(recognizedText)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }

            HStack(spacing: 20) {
                Button("🎤 음성 인식 시작") {
                    isListening = true
                    speechRecognizer.startRecording()
                }
                .disabled(isListening)

                Button("🛑 종료") {
                    speechRecognizer.stopRecording()
                    recognizedText = speechRecognizer.recognizedText
                    isListening = false
                }
                .disabled(!isListening)
            }

            Button("📤 메시지 전송") {
                let query = inputText.isEmpty ? recognizedText : inputText
                parseAndSendMessage(query: query)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            if !finalMessage.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📨 보낼 메시지:")
                    Text("받는 사람: \(toName)")
                    Text("내용: \(finalMessage)")
                        .font(.body)
                        .bold()

                    Button("💬 카카오톡으로 보내기") {
                        sendMessageWithKakaoSDK(text: finalMessage)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            if let error = errorMessage {
                Text("❌ \(error)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }

    // ✅ Flask 서버로 자연어 파싱 요청
    func parseAndSendMessage(query: String) {
        let baseURL: String

        #if DEBUG
        baseURL = "http://localhost:5001"
        #else
        baseURL = "http://3.36.86.32:5001"  // 실제 서버 주소로 교체
        #endif

        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/parseMessageCommand?query=\(encoded)") else {
            errorMessage = "URL 생성 실패"
            return
        }


        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "서버 연결 실패: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "서버 응답 없음"
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let to = json["to"] as? String,
                       let message = json["message"] as? String {
                        self.toName = to
                        self.finalMessage = message
                        self.errorMessage = nil
                    } else {
                        errorMessage = "JSON 파싱 실패"
                    }
                } catch {
                    errorMessage = "JSON 에러: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // ✅ Kakao SDK를 통한 메시지 전송
    func sendMessageWithKakaoSDK(text: String) {
        let template = TextTemplate(
            text: text,
            link: Link(
                webUrl: URL(string: "https://developers.kakao.com")!,
                mobileWebUrl: URL(string: "https://developers.kakao.com")!
            )
        )

        if LinkApi.isKakaoLinkAvailable() {
            LinkApi.shared.defaultLink(templatable: template) { linkResult, error in
                if let error = error {
                    print("❌ 메시지 전송 실패:", error)
                } else if let linkResult = linkResult {
                    UIApplication.shared.open(linkResult.url)
                }
            }
        } else {
            print("⚠️ 카카오톡 미설치 - 웹으로 전환 필요")
        }
    }
}

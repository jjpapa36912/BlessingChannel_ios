//
//  YouTubeHelperView.swift
//  BlessingChannel
//
//  Created by 김동준 on 7/12/25.
//

import SwiftUI
import AVFoundation
import Speech

struct YouTubeHelperView: View {
    @Binding var showYouTubeHelper: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    @State private var recognizedText: String = ""
    @State private var inputText: String = ""
    @State private var youtubeURL: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // 상단 바
            HStack {
                Button("← 뒤로가기") {
                    withAnimation {
                        showYouTubeHelper = false
                    }
                }
                .foregroundColor(.blue)
                Spacer()
                Text("🎬 유튜브 검색")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        showYouTubeHelper = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            Text("🗣️ 한국어 음성만 인식됩니다.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            // 음성 인식 결과 또는 실시간 표시
            if isListening || !recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(isListening ? "🎙️ 인식 중..." : "🗣️ 인식된 음성:")
                        .font(.subheadline)

                    Text(isListening ? speechRecognizer.recognizedText : recognizedText)
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    if isListening {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            }

            // 음성 인식 버튼
            HStack(spacing: 20) {
                Button("🎤 음성 인식 시작") {
                    isListening = true
                    recognizedText = ""
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

            // 텍스트 직접 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("✍️ 직접 검색어 입력")
                    .font(.subheadline)
                TextField("예: 아이폰15 리뷰, 김동률 노래", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // 검색 버튼
            Button("🔍 유튜브에서 검색") {
                let finalQuery = !inputText.trimmingCharacters(in: .whitespaces).isEmpty
                    ? inputText
                    : (!recognizedText.isEmpty ? recognizedText : speechRecognizer.recognizedText)

                fetchYouTubeLink(from: finalQuery)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)

            // 결과 링크
            if let url = URL(string: youtubeURL), !youtubeURL.isEmpty {
                Button("🔗 유튜브 열기") {
                    UIApplication.shared.open(url)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            // 에러 메시지
            if let error = errorMessage {
                Text("❌ \(error)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }

    func fetchYouTubeLink(from query: String) {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            errorMessage = "검색어를 입력하거나 음성으로 말해주세요."
            return
        }

        let baseURL: String
        #if DEBUG
        baseURL = "http://localhost:5001"
        #else
        baseURL = "http://13.124.208.108:5001"
        #endif

        guard let encoded = cleaned.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/getYouTubeLink?query=\(encoded)") else {
            errorMessage = "검색어를 처리할 수 없습니다."
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "응답이 없습니다."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let link = json["url"] as? String {
                        youtubeURL = link
                        errorMessage = nil
                    } else {
                        errorMessage = "검색 결과를 찾지 못했습니다."
                    }
                } catch {
                    errorMessage = "데이터 처리 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


////
////  YouTubeHelperView.swift
////  BlessingChannel
////
////  Created by 김동준 on 7/12/25.
////
//
//import Foundation
//import SwiftUI
//import AVFoundation
//import Speech
//
//import SwiftUI
//import Speech
//
//struct YouTubeHelperView: View {
//    @Binding var showYouTubeHelper: Bool
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var isListening = false
//    @State private var recognizedText: String = ""
//    @State private var inputText: String = ""          // ✅ 사용자 직접 입력 텍스트
//    @State private var youtubeURL: String = ""
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack(spacing: 16) {
//            HStack {
//                Button("← 뒤로가기") {
//                    withAnimation {
//                        showYouTubeHelper = false
//                    }
//                }
//                .foregroundColor(.blue)
//                Spacer()
//                Text("🎬 유튜브 검색")
//                    .font(.headline)
//                Spacer()
//                Button {
//                    withAnimation {
//                        showYouTubeHelper = false
//                    }
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                }
//            }
//            VStack(spacing: 10) {
//                if isListening {
//                    // 🎙️ 실시간 인식 중
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("🗣️ 인식 중...")
//                            .font(.subheadline)
//
//                        Text(speechRecognizer.recognizedText.isEmpty ? "음성이 인식되는 중입니다..." : speechRecognizer.recognizedText)
//                            .font(.body)
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding()
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(8)
//
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .padding(.top, 4)
//                    }
//                } else if !recognizedText.isEmpty {
//                    // 🛑 인식 종료 후 최종 텍스트
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("🗣️ 인식된 음성:")
//                            .font(.subheadline)
//
//                        Text(recognizedText)
//                            .font(.body)
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding()
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(8)
//                    }
//                }
//
//                HStack(spacing: 20) {
//                    Button("🎤 음성 인식 시작") {
//                        isListening = true
//                        recognizedText = ""  // 시작 시 이전 인식 결과 초기화 (선택사항)
//                        speechRecognizer.startRecording()
//                    }
//                    .disabled(isListening)
//
//                    Button("🛑 종료") {
//                        speechRecognizer.stopRecording()
//                        recognizedText = speechRecognizer.recognizedText
//                        isListening = false
//                    }
//                    .disabled(!isListening)
//                }
//            }
//
//
////            VStack(alignment: .leading, spacing: 8) {
////                Text("✍️ 검색어 입력")
////                    .font(.subheadline)
////                TextField("예: 아이폰15 리뷰, 김동률 노래", text: $inputText)
////                    .textFieldStyle(RoundedBorderTextFieldStyle())
////            }
////
////            VStack(alignment: .leading, spacing: 8) {
////                Text("🗣️ 인식된 음성:")
////                    .font(.subheadline)
////                Text(recognizedText)
////                    .font(.body)
////                    .foregroundColor(.gray)
////                    .frame(maxWidth: .infinity, alignment: .leading)
////                    .padding()
////                    .background(Color(.secondarySystemBackground))
////                    .cornerRadius(8)
////            }
////
////            HStack(spacing: 20) {
////                Button("🎤 음성 인식 시작") {
////                    isListening = true
////                    speechRecognizer.startRecording()
////                }
////                .disabled(isListening)
////
////                Button("🛑 종료") {
////                    speechRecognizer.stopRecording()
////                    recognizedText = speechRecognizer.recognizedText
////                    isListening = false
////                }
////                .disabled(!isListening)
////            }
//
//            Button("🔍 유튜브에서 검색") {
//                let finalQuery = inputText.isEmpty ? recognizedText : inputText
//                fetchYouTubeLink(from: finalQuery)
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.red)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            if let url = URL(string: youtubeURL), !youtubeURL.isEmpty {
//                Button("🔗 링크 열기") {
//                    UIApplication.shared.open(url)
//                }
//                .padding()
//                .background(Color.green)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
//
//            if let error = errorMessage {
//                Text("❌ \(error)")
//                    .foregroundColor(.red)
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//
//    func fetchYouTubeLink(from query: String) {
//        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
//            errorMessage = "검색어를 입력하거나 음성으로 말해주세요."
//            return
//        }
//
//        let baseURL: String
//
//        #if DEBUG
//        baseURL = "http://localhost:5001"
//        #else
//        baseURL = "http://13.124.208.108:5001" // 🔁 실제 서버 주소로 교체
//        #endif
//
//        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: "\(baseURL)/getYouTubeLink?query=\(encoded)") else {
//            errorMessage = "URL 생성 실패"
//            return
//        }
//
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let data = data else {
//                    errorMessage = "응답 없음"
//                    return
//                }
//
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let link = json["url"] as? String {
//                        youtubeURL = link
//                        errorMessage = nil
//                    } else {
//                        errorMessage = "링크 파싱 실패"
//                    }
//                } catch {
//                    errorMessage = "JSON 에러: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//}

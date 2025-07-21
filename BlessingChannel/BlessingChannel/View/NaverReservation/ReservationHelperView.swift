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
    @State private var recognizedText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    withAnimation { showReservationHelper = false }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                Spacer()
                Text("예약 도우미")
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation { showReservationHelper = false }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }

            // 입력 필드
            VStack(alignment: .leading, spacing: 8) {
                Text("예약 명령 입력")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("예: 세종시에 있는 서울현병원 예약하고 싶어", text: $userQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // 음성 인식
            VStack(spacing: 12) {
                if isListening {
                    HStack {
                        ProgressView()
                        Text("음성 인식 중...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else if !recognizedText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("인식된 문장")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(recognizedText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }

                HStack(spacing: 16) {
                    Button(action: {
                        isListening = true
                        recognizedText = ""
                        speechRecognizer.startRecording()
                    }) {
                        Text("음성 인식 시작")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isListening)

                    Button(action: {
                        speechRecognizer.stopRecording()
                        recognizedText = speechRecognizer.recognizedText
                        userQuery = recognizedText
                        isListening = false
                    }) {
                        Text("종료")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .disabled(!isListening)
                }
            }

            // 예약 링크 요청 버튼
            Button(action: fetchReservationLink) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("예약 링크 찾기")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(userQuery.isEmpty || isLoading)

            // 에러 메시지
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // 결과
            if !parsedName.isEmpty {
                VStack(spacing: 10) {
                    Text("예약 대상: \(parsedName)")
                        .font(.headline)
                    Button("예약 페이지 열기") {
                        if let url = URL(string: bookingURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    func fetchReservationLink() {
        isLoading = true
        errorMessage = nil
        parsedName = ""
        bookingURL = ""

        let baseURL: String = {
            #if DEBUG
            return "http://localhost:5001"
            #else
            return "http://13.124.208.108:5001"
            #endif
        }()

        guard let encoded = userQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/getReservationLink?query=\(encoded)") else {
            errorMessage = "잘못된 요청입니다."
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
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


////
////  ReservationHelperView.swift
////  BlessingChannel
////
////  Created by 김동준 on 7/12/25.
////
//
//import Foundation
//import SwiftUI
//
//struct ReservationHelperView: View {
//    @Binding var showReservationHelper: Bool
//    @State private var userQuery: String = ""
//    @State private var bookingURL: String = ""
//    @State private var parsedName: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var isListening = false
//    @State private var recognizedText: String = ""
//
//    var body: some View {
//        VStack(spacing: 16) {
//            // 상단 헤더
//            HStack {
//                Button("← 뒤로가기") {
//                    withAnimation {
//                        showReservationHelper = false
//                    }
//                }
//                .foregroundColor(.blue)
//                Spacer()
//                Text("🗣️ 음성 예약 도우미")
//                    .font(.headline)
//                Spacer()
//                Button {
//                    withAnimation {
//                        showReservationHelper = false
//                    }
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                }
//            }
//
//            // 입력 필드
//            VStack(alignment: .leading, spacing: 8) {
//                Text("✍️ 예약 명령 입력")
//                    .font(.subheadline)
//                TextField("예: 세종시에 있는 서울현병원 예약하고 싶어", text: $userQuery)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//
//            // 음성 인식 영역
//            VStack(spacing: 10) {
//                if isListening {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("🗣️ 인식 중...")
//                            .font(.subheadline)
//
//                        Text(speechRecognizer.recognizedText.isEmpty ? "음성이 인식되는 중입니다..." : speechRecognizer.recognizedText)
//                            .font(.body)
//                            .foregroundColor(.gray)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(8)
//
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .padding(.top, 4)
//                    }
//                } else if !recognizedText.isEmpty {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("🗣️ 인식된 음성:")
//                            .font(.subheadline)
//
//                        Text(recognizedText)
//                            .font(.body)
//                            .foregroundColor(.gray)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(8)
//                    }
//                }
//
//                HStack(spacing: 20) {
//                    Button("🎤 음성 인식 시작") {
//                        isListening = true
//                        recognizedText = ""
//                        speechRecognizer.startRecording()
//                    }
//                    .disabled(isListening)
//
//                    Button("🛑 종료") {
//                        speechRecognizer.stopRecording()
//                        recognizedText = speechRecognizer.recognizedText
//                        userQuery = recognizedText
//                        isListening = false
//                    }
//                    .disabled(!isListening)
//                }
//            }
//
//            // 예약 요청 버튼
//            Button {
//                fetchReservationLink()
//            } label: {
//                if isLoading {
//                    ProgressView()
//                } else {
//                    Text("🔍 예약 링크 찾기")
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                }
//            }
//            .disabled(userQuery.isEmpty || isLoading)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            // 에러 메시지
//            if let errorMessage = errorMessage {
//                Text("❌ \(errorMessage)")
//                    .foregroundColor(.red)
//            }
//
//            // 결과 표시
//            if !parsedName.isEmpty {
//                VStack(spacing: 8) {
//                    Text("🔍 추출된 예약 대상:")
//                        .font(.subheadline)
//                    Text(parsedName)
//                        .font(.title3)
//                        .bold()
//
//                    Button("🔗 예약 페이지 열기") {
//                        if let url = URL(string: bookingURL) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//
//    func fetchReservationLink() {
//        isLoading = true
//        errorMessage = nil
//        parsedName = ""
//        bookingURL = ""
//
//        let baseURL: String
//
//        #if DEBUG
//        baseURL = "http://localhost:5001"
//        #else
//        baseURL = "http://13.124.208.108:5001"
//        #endif
//
//        guard let encoded = userQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: "\(baseURL)/getReservationLink?query=\(encoded)") else {
//            errorMessage = "잘못된 요청입니다."
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let error = error {
//                    errorMessage = "네트워크 에러: \(error.localizedDescription)"
//                    return
//                }
//
//                guard let data = data else {
//                    errorMessage = "데이터를 받지 못했습니다."
//                    return
//                }
//
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                        if let name = json["parsed_name"] as? String,
//                           let link = json["url"] as? String {
//                            parsedName = name
//                            bookingURL = link
//                        } else if let err = json["error"] as? String {
//                            errorMessage = "서버 오류: \(err)"
//                        } else {
//                            errorMessage = "응답 파싱 실패"
//                        }
//                    }
//                } catch {
//                    errorMessage = "JSON 디코딩 실패: \(error)"
//                }
//            }
//        }.resume()
//    }
//}
//

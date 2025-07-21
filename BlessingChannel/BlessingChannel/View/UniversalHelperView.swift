import SwiftUI
import Speech
import KakaoSDKTemplate
import KakaoSDKLink

enum HelperType: CaseIterable, Hashable {
    case coupang
    case youtube
    case reservation
    case kakao

    var title: String {
        switch self {
        case .coupang: return "쿠팡 검색"
        case .youtube: return "유튜브 검색"
        case .reservation: return "네이버 예약 도우미"
        case .kakao: return "카카오 메시지"
        }
    }

    var placeholder: String {
        switch self {
        case .coupang: return "예: 맥북 케이스, 아이패드 거치대"
        case .youtube: return "예: 이적 노래 검색"
        case .reservation: return "예: 세종 서울현병원 예약하고 싶어"
        case .kakao: return "예: 엄마에게 사랑한다고 보내줘"
        }
    }

    var buttonText: String {
        switch self {
        case .coupang: return "쿠팡에서 검색"
        case .youtube: return "유튜브에서 검색"
        case .reservation: return "예약 링크 찾기"
        case .kakao: return "카카오톡 메시지 보내기"
        }
    }

    var requestURL: String {
        switch self {
        case .coupang: return "/getCoupangLink"
        case .youtube: return "/getYouTubeLink"
        case .reservation: return "/getReservationLink"
        case .kakao: return "/parseMessageCommand"
        }
    }
    var emoji: String {
        switch self {
        case .coupang: return ""
        case .youtube: return ""
        case .reservation: return ""
        case .kakao: return ""
        }
    }

    var instruction: String {
        switch self {
        case .coupang: return "예: 맥북 케이스, 아이패드 거치대"
        case .youtube: return "예: 이적 노래"
        case .reservation: return "예: 세종 서울현병원 예약하고 싶어"
        case .kakao: return "예: 엄마에게 사랑한다고 보내줘"
        }
    }

}

struct UniversalHelperView: View {
    @Binding var isPresented: Bool
    let helperType: HelperType

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    @State private var inputText: String = ""
    @State private var resultURL: String = ""
    @State private var parsedInfo: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // 상단 헤더
            HStack {
                Button("← 뒤로가기") {
                    withAnimation { isPresented = false }
                }
                .foregroundColor(.blue)
                Spacer()
                Text(helperType.title)
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            // 입력 필드
            TextField(helperType.placeholder, text: $inputText)
                .onChange(of: speechRecognizer.recognizedText) { newText in
                    inputText = newText
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // 음성 인식 UI
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
                        inputText = speechRecognizer.recognizedText
                        isListening = false
                    }
                    .disabled(!isListening)
                }
            }

            // 검색 버튼
            Button(helperType.buttonText) {
                fetchLink(for: inputText)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            // 결과
            if !parsedInfo.isEmpty {
                Text("🔍 결과 요약: \(parsedInfo)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                // ✅ 여기에 카카오 메시지 전송 버튼 추가
                    if helperType == .kakao {
                        Button("💬 카카오톡으로 보내기") {
                            sendMessageWithKakaoSDK(text: parsedInfo)
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
            }

            if let url = URL(string: resultURL), !resultURL.isEmpty {
                Button("🔗 링크 열기") {
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

            // 언어 지원 안내
            Text("※ 음성 인식은 한국어만 지원됩니다.")
                .font(.footnote)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
    
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

    private func fetchLink(for query: String) {
        errorMessage = nil
        parsedInfo = ""
        resultURL = ""

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "검색어를 입력하거나 음성으로 말해주세요."
            return
        }

        let baseURL: String
        #if DEBUG
        baseURL = "http://localhost:5001"
        #else
        baseURL = "http://13.124.208.108:5001"
        #endif

        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)\(helperType.requestURL)?query=\(encoded)") else {
            errorMessage = "요청 URL 생성 실패"
            return
        }
        
        // ⏱️ 요청 시작 시점
        let start = Date()

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
            // ⏱️ 응답 도착 및 렌더링 시작 시점
            let elapsed = Date().timeIntervalSince(start)
            print("⏱️ 전체 API 응답 + UI 반영 시간: \(elapsed)초")
                if let error = error {
                    self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "응답 데이터가 없습니다."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        // ✅ 애니메이션으로 상태 업데이트
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if let link = json["url"] as? String {
                                        self.resultURL = link
                                    }

                                    if let info = json["parsed_name"] as? String {
                                        self.parsedInfo = info
                                    } else if let info = json["message"] as? String {
                                        self.parsedInfo = info
                                    }
                                }

                        if let errorText = json["error"] as? String {
                            self.errorMessage = errorText
                        }

                    } else {
                        self.errorMessage = "JSON 파싱 실패"
                    }
                } catch {
                    self.errorMessage = "JSON 디코딩 에러: \(error.localizedDescription)"
                }

            }
        }.resume()
    }
    

}

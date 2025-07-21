import SwiftUI
import Speech

enum HelperType {
    case coupang, youtube, reservation

    var title: String {
        switch self {
        case .coupang: return "🛒 쿠팡 검색"
        case .youtube: return "🎬 유튜브 검색"
        case .reservation: return "🏥 병원 예약"
        }
    }

    var buttonTitle: String {
        switch self {
        case .coupang: return "🔍 쿠팡에서 검색"
        case .youtube: return "🔍 유튜브에서 검색"
        case .reservation: return "🔍 예약 링크 찾기"
        }
    }

    var placeholder: String {
        switch self {
        case .coupang: return "예: 맥북 케이스, 생수"
        case .youtube: return "예: 아이폰15 리뷰, 요리 레시피"
        case .reservation: return "예: 신촌 연세병원 예약하고 싶어"
        }
    }

    var endpoint: String {
        switch self {
        case .coupang: return "/getCoupangLink?query="
        case .youtube: return "/getYouTubeLink?query="
        case .reservation: return "/getReservationLink?query="
        }
    }
}

struct UniversalHelperView: View {
    @Binding var isPresented: Bool
    let helperType: HelperType

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var inputText = ""
    @State private var resultURL = ""
    @State private var parsedName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // 헤더
            HStack {
                Button("← 뒤로가기") {
                    withAnimation { isPresented = false }
                }
                .foregroundColor(.blue)
                Spacer()
                Text(helperType.title).font(.headline)
                Spacer()
                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }

            // 음성 인식 설명
            Text("🗣️ 한국어 음성만 인식됩니다.")
                .font(.caption)
                .foregroundColor(.secondary)

            // 음성 실시간/결과
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

            // 음성 버튼
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

            // 입력 필드
            VStack(alignment: .leading, spacing: 8) {
                Text("✍️ 직접 입력").font(.subheadline)
                TextField(helperType.placeholder, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // 검색 버튼
            Button(action: {
                let query = inputText.trimmingCharacters(in: .whitespaces).isEmpty
                    ? (recognizedText.isEmpty ? speechRecognizer.recognizedText : recognizedText)
                    : inputText
                fetchLink(from: query)
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(helperType.buttonTitle)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)

            // 결과 표시
            if helperType == .reservation && !parsedName.isEmpty {
                VStack(spacing: 8) {
                    Text("🔍 추출된 예약 대상:").font(.subheadline)
                    Text(parsedName).font(.title3).bold()
                }
            }

            if let url = URL(string: resultURL), !resultURL.isEmpty {
                Button("🔗 열기") {
                    UIApplication.shared.open(url)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            if let error = errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }

    func fetchLink(from query: String) {
        isLoading = true
        errorMessage = nil
        parsedName = ""
        resultURL = ""

        let baseURL: String
        #if DEBUG
        baseURL = "http://localhost:5001"
        #else
        baseURL = "http://13.124.208.108:5001"
        #endif

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "검색어를 입력하거나 음성으로 말해주세요."
            isLoading = false
            return
        }

        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: baseURL + helperType.endpoint + encoded) else {
            errorMessage = "URL 생성 실패"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "응답이 없습니다."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if helperType == .reservation {
                            parsedName = json["parsed_name"] as? String ?? ""
                        }
                        resultURL = json["url"] as? String ?? ""
                        if let link = URL(string: resultURL), helperType == .reservation {
                            UIApplication.shared.open(link)
                        }
                    } else {
                        errorMessage = "결과 처리 실패"
                    }
                } catch {
                    errorMessage = "JSON 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

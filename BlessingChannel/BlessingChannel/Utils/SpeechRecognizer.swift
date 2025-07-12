//
//  SpeechRecognizer.swift
//  BlessingChannel
//
//  Created by 김동준 on 7/12/25.
//

import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var recognizedText: String = ""

    func startRecording() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Speech recognition not authorized")
                return
            }

            DispatchQueue.main.async {
                self.startSession()
            }
        }
    }

    private func startSession() {
        if audioEngine.isRunning {
            stopRecording()
        }

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

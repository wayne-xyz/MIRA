import SwiftUI
import AVFoundation
import Speech
class SpeechRecognizer: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer()
    
    var onCommandDetected: ((String) -> Void)?
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    self.transcribedText = "Speech recognition not authorized."
                }
            }
        }
    }
    
    func startRecording() {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            transcribedText = "Speech recognition not authorized."
            return
        }
        
        audioEngine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine?.inputNode else {
            transcribedText = "Audio input node unavailable."
            return
        }
        
        // Reset transcribed text at the start of each recording session
        transcribedText = ""
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine?.prepare()
        
        do {
            try audioEngine?.start()
            isRecording = true
            print("Started recording...")
        } catch {
            transcribedText = "Failed to start audio engine."
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request!) { result, error in
            if let result = result, !result.isFinal {
                // Update only if valid text is detected
                let newTranscription = result.bestTranscription.formattedString
                if !newTranscription.isEmpty {
                    self.transcribedText = newTranscription
                    print("Transcription updated: \(self.transcribedText)")
                }
            } else if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self.stopRecording()  // Stop on error, do not update with error message
            }
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
        print("Stopped recording.")
        
        // Ensure only meaningful and unique text is sent
        let trimmedText = transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            onCommandDetected?(trimmedText)
        }
        transcribedText = ""  // Clear to prevent duplicate triggers
    }
}

//
//  SpeechRecognizer.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

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
    
    // Completion handler to trigger when "Hey Mira" and the following command are detected
    var onCommandDetected: ((String) -> Void)?
    private var isListeningForCommand = false
    private var silenceTimer: Timer?
    
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
        
        let inputNode = audioEngine?.inputNode
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine?.prepare()
        
        do {
            try audioEngine?.start()
            isRecording = true
        } catch {
            transcribedText = "Failed to start audio engine."
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request!) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                self.detectKeyword(in: self.transcribedText)
            } else if let error = error {
                self.transcribedText = "Error: \(error.localizedDescription)"
                self.restartRecording()  // Restart on error
            }
        }
    }
    
    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }
    
    // Detect "Hey Mira" and capture the command following it
    private func detectKeyword(in text: String) {
        let keyword = "hey mira"
        
        if isListeningForCommand {
            // Restart silence timer to detect pauses
            resetSilenceTimer()
        } else if let range = text.lowercased().range(of: keyword) {
            // Start listening for the command after "Hey Mira" is detected
            isListeningForCommand = true
            transcribedText = String(text[range.lowerBound...])  // Start capturing after "Hey Mira"
            resetSilenceTimer()  // Start timer to detect end of command
        }
    }
    
    // Restart the timer to detect a pause in the user's speech
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.processCommand()
        }
    }
    
    // Process the command when the user stops speaking for 3 seconds
    private func processCommand() {
        stopRecording()
        
        // Extract command text after "Hey Mira"
        let keyword = "hey mira"
        let text = transcribedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = text.range(of: keyword) {
            let command = text[range.upperBound...].trimmingCharacters(in: .whitespaces)
            onCommandDetected?(String(command))
        } else {
            onCommandDetected?(transcribedText)
        }
        
        isListeningForCommand = false
        transcribedText = ""
        restartRecording()  // Restart listening for "Hey Mira" again
    }
    
    // Restart recording for continuous listening
    private func restartRecording() {
        stopRecording()
        startRecording()
    }
}

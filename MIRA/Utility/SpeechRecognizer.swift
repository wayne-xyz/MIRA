//
//  SpeechRecognizer.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//  Modified by Jarin Thundathil on 11/9/24

import SwiftUI
import AVFoundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var language = Locale(identifier: "en-US")  // Default to English
    private var isTranslating = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))  // Default recognizer
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
        
        recognitionTask = SFSpeechRecognizer(locale: language)?.recognitionTask(with: request!) { result, error in
            if let result = result, !result.isFinal {
                self.transcribedText = result.bestTranscription.formattedString
                if self.isTranslating {
                    self.detectKeyword(in: self.transcribedText)
                }
                if !self.transcribedText.isEmpty {
                    print("Transcription updated: \(self.transcribedText)")
                }
            } else if let error = error {
                self.transcribedText = "Error: \(error.localizedDescription)"
                self.stopRecording()
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
    
    private func detectKeyword(in text: String) {
        let keyword = "hey mira"
        
        if isListeningForCommand {
            resetSilenceTimer()
        } else if let range = text.lowercased().range(of: keyword) {
            isListeningForCommand = true
            transcribedText = String(text[range.lowerBound...])
            resetSilenceTimer()
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.processCommand()
        }
    }
    
    private func processCommand() {
        stopRecording()
        
        let keyword = "hey mira"
        let text = transcribedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let range = text.range(of: keyword) {
            let command = text[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if command.contains("translate") {
                self.language = Locale(identifier: "zh-CN")  // Set to Mandarin for translation
                self.isTranslating = true
                transcribedText = "Listening for Mandarin speech..."
                startRecording()
            } else {
                onCommandDetected?(String(command))
            }
        }
        
        isListeningForCommand = false
        transcribedText = ""
        restartRecording()
    }
    
    private func restartRecording() {
        stopRecording()
        startRecording()
    }
    
    private func translate(text: String) {
        // Add Google Translate API call here (refer to previous implementation).
        GoogleTranslateAPI().translate(text: text) { translatedText in
            DispatchQueue.main.async {
                self.transcribedText = translatedText ?? "Translation failed."
            }
        }
    }
}

//
//  ChatGPTSpeechView.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//
import SwiftUI
struct ChatGPTSpeechView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var textSpeaker = TextSpeaker()
    @State private var responseText: String = "Waiting for your command..."
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Speak to ChatGPT")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            Text("You said:")
                .font(.headline)
                .padding(.top)
            Text(speechRecognizer.transcribedText)
                .padding()
                .frame(width: 400, height: 100)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .padding()
            
            Button(action: toggleRecording) {
                Text(speechRecognizer.isRecording ? "Stop & Send to ChatGPT" : "Summon Mira")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(speechRecognizer.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            } else {
                Text("Response from ChatGPT:")
                    .font(.headline)
                    .padding(.top)
                Text(responseText)
                    .padding()
                    .frame(width: 400, height: 200)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .padding()
            }
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 400)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            setupCommandDetection()
        }
    }
    
    private func setupCommandDetection() {
        speechRecognizer.onCommandDetected = { [self] command in
            print("Command detected: \(command)")
            responseText = "Processing your request..."
            isLoading = true
            sendToChatGPT(command)
        }
    }
    private func toggleRecording() {
        if speechRecognizer.isRecording {
            print("Stopping recording and processing command.")
            speechRecognizer.stopRecording()
            
            // Only process valid transcriptions that haven’t been sent
            let command = speechRecognizer.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !command.isEmpty && responseText != command {
                responseText = "Processing your request..."
                sendToChatGPT(command)
            } else {
                print("No valid speech input detected or duplicate detected, doing nothing.")
                responseText = "Waiting for your command..." // Reset message, no error shown
            }
        } else {
            print("Starting recording...")
            responseText = "Waiting for your command..."
            errorMessage = nil
            speechRecognizer.startRecording()
        }
    }
    private func sendToChatGPT(_ prompt: String) {
        guard !prompt.isEmpty else {
            responseText = "No command detected."
            return
        }
        
        print("Sending prompt to ChatGPT: \(prompt)")
        isLoading = true
        NetworkManager.shared.sendChatGPTPrompt(prompt) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let text):
                    print("Received response from ChatGPT: \(text)")
                    self.responseText = text
                    self.errorMessage = nil
                    self.textSpeaker.speakText(text)
                case .failure(let error):
                    print("Error from ChatGPT: \(error.localizedDescription)")
                    self.responseText = "Error: \(error.localizedDescription)"
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

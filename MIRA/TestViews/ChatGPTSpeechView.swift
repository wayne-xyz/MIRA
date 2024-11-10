//
//  ChatGPTSpeechView.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import SwiftUI

struct ChatGPTSpeechView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var textSpeaker = TextSpeaker()  // Added TextSpeaker instance
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
            print("View appeared, starting recording...")
            speechRecognizer.startRecording()
        }
        .onDisappear {
            print("View disappeared, stopping recording...")
            speechRecognizer.stopRecording()
        }
    }
    
    private func setupCommandDetection() {
        speechRecognizer.onCommandDetected = { [self] command in
            print("Command detected: \(command)") // Debug: Verify command capture
            responseText = "Processing your request..."
            isLoading = true
            sendToChatGPT(command)
        }
    }

    private func sendToChatGPT(_ prompt: String) {
        guard !prompt.isEmpty else {
            responseText = "No command detected after 'Hey Mira'."
            return
        }
        
        print("Sending prompt to ChatGPT: \(prompt)") // Debug: Verify prompt submission
        
        NetworkManager.shared.sendChatGPTPrompt(prompt) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let text):
                    print("Received response from ChatGPT: \(text)") // Debug: Check response
                    self.responseText = text
                    self.errorMessage = nil
                    self.textSpeaker.speakText(text)  // Make the response read aloud
                case .failure(let error):
                    print("Error from ChatGPT: \(error.localizedDescription)") // Debug: Check error
                    self.responseText = "Error: \(error.localizedDescription)"
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

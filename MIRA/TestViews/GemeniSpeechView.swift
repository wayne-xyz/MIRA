//
//  GeminiSpeechView.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import SwiftUI

struct GeminiSpeechView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var responseText: String = "Waiting for your command..."
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Speak to Gemini")
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
                Text("Response from Gemini:")
                    .font(.headline)
                    .padding(.top)
                Text(responseText)
                    .padding()
                    .frame(width: 400, height: 200)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupCommandDetection()
            speechRecognizer.startRecording()
        }
        .onDisappear {
            speechRecognizer.stopRecording()
        }
    }
    
    private func setupCommandDetection() {
        speechRecognizer.onCommandDetected = { [self] command in
            responseText = "Processing your request..."
            isLoading = true
            sendToGemini(command)
        }
    }

    private func sendToGemini(_ prompt: String) {
        guard !prompt.isEmpty else {
            responseText = "No command detected after 'Hey Mira'."
            return
        }
        
        NetworkManager.shared.sendGeminiPrompt(prompt) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let text):
                    self.responseText = text
                case .failure(let error):
                    self.responseText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

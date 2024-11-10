//
//  GeminiTestView.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import SwiftUI

struct GeminiTestView: View {
    @State private var prompt: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Ask Gemini")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            TextField("Enter your question...", text: $prompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(width: 400)
                .onSubmit {
                    submitPrompt()
                }

            Button(action: submitPrompt) {
                Text("Send to Gemini")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }

            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 400)
            } else if !response.isEmpty {
                Text("Response from Gemini:")
                    .font(.headline)
                    .padding(.top)
                Text(response)
                    .padding()
                    .frame(width: 400, height: 200)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func submitPrompt() {
        guard !prompt.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        response = ""
        
        NetworkManager.shared.sendGeminiPrompt(prompt) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let text):
                    self.response = text
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

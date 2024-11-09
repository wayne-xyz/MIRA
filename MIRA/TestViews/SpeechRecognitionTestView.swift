//
//  SpeechRecognitionTestView.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import SwiftUI

struct SpeechRecognitionTestView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
        
        var body: some View {
            VStack {
                Text(speechRecognizer.transcribedText)
                    .padding()
                    .font(.title)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding()
                
                Button(action: {
                    if speechRecognizer.isRecording {
                        speechRecognizer.stopRecording()
                    } else {
                        speechRecognizer.startRecording()
                    }
                }) {
                    Text(speechRecognizer.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(speechRecognizer.isRecording ? Color.red : Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
}

#Preview {
    SpeechRecognitionTestView()
}

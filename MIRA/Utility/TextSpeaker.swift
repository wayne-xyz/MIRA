//
//  TextSpeaker.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

// TTS Manager Class
import AVFoundation

class TextSpeaker: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    // Method to speak the given text
    func speakText(_ text: String) {
        // Create the speech utterance with the text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // You can set other languages here
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        
        // Start speaking the text
        synthesizer.speak(utterance)
    }
}

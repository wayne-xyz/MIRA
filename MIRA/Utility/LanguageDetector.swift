//
//  LanguageDetector.swift
//  MIRA
//
//  Created by Rongwei Ji on 11/9/24.
//

import SwiftUI
import NaturalLanguage

class LanguageDetector: ObservableObject {
    @Published var detectedLanguage: String? = nil
    
    func detectLanguage(for text: String) {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let languageCode = recognizer.dominantLanguage?.rawValue {
            let locale = Locale.current.localizedString(forLanguageCode: languageCode) ?? languageCode
            DispatchQueue.main.async {
                self.detectedLanguage = locale.capitalized
            }
        } else {
            DispatchQueue.main.async {
                self.detectedLanguage = "Unknown"
            }
        }
    }
}

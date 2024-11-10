//
//  SpeechTranslator.swift
//  MIRA
//
//  Created by Jarin Thundathil on 2024-11-09.
//

import Foundation

struct GoogleTranslateAPI {
    let apiKey = "AIzaSyClnxizpg-RrIUzJSOu0KOdQEL_0wcGsxI"  // Replace with your actual API key
    let targetLanguage = "en"
    
    func translate(text: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonRequest: [String: Any] = [
            "q": text,
            "target": targetLanguage,
            "format": "text",
            "key": apiKey
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        } catch {
            print("Error serializing JSON:", error)
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Translation request error:", error)
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let translations = data["translations"] as? [[String: Any]],
                   let translatedText = translations.first?["translatedText"] as? String {
                    completion(translatedText)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

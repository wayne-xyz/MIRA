//
//  NetworkManager.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import Foundation

class NetworkManager {
 
    static let shared = NetworkManager()
    private let openAIKey = ""
    private let chatGPTApiUrl = "https://api.openai.com/v1/chat/completions"

    private init() {} // Private initializer to enforce singleton pattern

    func sendChatGPTPrompt(_ prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let timeRecord = TimeRecordManager.shared
        
        // Check if enough time has passed since last request
        if let lastRequestTime = timeRecord.getTimeRecord(for: "GPTTime") {
            let currentTime = Date()
            let timeDifference = currentTime.timeIntervalSince(lastRequestTime)
            print("TimDiffere\(timeDifference)")
            // If less than 3 seconds have passed since last request
            if timeDifference < 10 {
                completion(.failure(NSError(domain: "RateLimitError", 
                                         code: 429, 
                                         userInfo: [NSLocalizedDescriptionKey: "Please wait before making another request."])))
                return
            }
        }
        
        // Record current time for this request
        timeRecord.saveTimeRecord(for: "GPTTime")
    
        
        guard !prompt.isEmpty else {
            completion(.failure(NSError(domain: "PromptError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Prompt cannot be empty."])))
            return
        }

        var request = URLRequest(url: URL(string: chatGPTApiUrl)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 100
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }


            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let errorMessage = "Server error: \(statusCode)"
                completion(.failure(NSError(domain: "ServerError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                completion(.failure(NSError(domain: "ResponseParsingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response."])))
                return
            }

            completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
        }.resume()
    }
}

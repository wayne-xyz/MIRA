//
//  NetworkManager.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
    private let apiKey = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"]!

    private init() {}

    func sendGeminiPrompt(_ prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !prompt.isEmpty else {
            completion(.failure(NSError(domain: "PromptError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Prompt cannot be empty."])))
            return
        }

        guard let url = URL(string: "\(geminiApiUrl)?key=\(apiKey)") else {
            completion(.failure(NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body as per the Google Gemini API format
        let parameters: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
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

            guard let data = data else {
                completion(.failure(NSError(domain: "ResponseParsingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                return
            }

            // Attempt to decode the JSON response into GeminiResponse
            do {
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                if let text = decodedResponse.candidates.first?.content.parts.first?.text {
                    completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completion(.failure(NSError(domain: "ResponseParsingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "No text content found in response."])))
                }
            } catch {
                completion(.failure(NSError(domain: "ResponseParsingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response JSON: \(error.localizedDescription)"])))
            }
        }.resume()
    }
}

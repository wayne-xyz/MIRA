import Foundation

class SkyboxGenerator {
    private let apiKey: String
    private let baseUrl = "https://backend.blockadelabs.com/api/v1/skybox"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateSkybox(skyboxStyleId: Int, prompt: String, negativeText: String? = nil, enhancePrompt: Bool = false, seed: Int? = nil, completion: @escaping (Result<SkyboxResponse, Error>) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: Any] = [
            "skybox_style_id": skyboxStyleId,
            "prompt": prompt,
            "enhance_prompt": enhancePrompt
        ]
        
        if let negativeText = negativeText {
            parameters["negative_text"] = negativeText
        }
        
        if let seed = seed {
            parameters["seed"] = seed
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let skyboxResponse = try JSONDecoder().decode(SkyboxResponse.self, from: data)
                completion(.success(skyboxResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    
    
    
    
}

// Skybox response structure
struct SkyboxResponse: Codable {
    let id: Int
    let skyboxStyleId: Int
    let skyboxStyleName: String
    let model: String
    let status: String
    let queuePosition: Int
    let fileUrl: String?
    let thumbUrl: String?
    let obfuscatedId: String
    let errorMessage: String?
    let createdAt: String
    let updatedAt: String
}

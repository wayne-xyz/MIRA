import Foundation
import UIKit

class SkyboxGenerator {
    private let apiKey: String
    private let baseURL = "https://backend.blockadelabs.com/api/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // Method to generate a skybox based on a text prompt
    func generateSkybox(prompt: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/skybox") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["prompt": prompt]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let id = json["id"] as? Int {
                    completion("\(id)", nil)
                } else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Method to check generation status
    func checkStatus(for id: String, completion: @escaping (String?, String?, String?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/imagine/requests/\(id)") else {
            completion(nil, nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, nil, nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? String,
                   let fileURL = json["file_url"] as? String,
                   let thumbURL = json["thumb_url"] as? String {
                    completion(status, fileURL, thumbURL, nil)
                } else {
                    completion(nil, nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"]))
                }
            } catch {
                completion(nil, nil, nil, error)
            }
        }.resume()
    }
    
    // Method to download image file and optionally save it locally
    func downloadImage(from url: String, saveLocally: Bool = false, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"]))
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil, error)
                return
            }
            
            if saveLocally, let imageData = image.pngData() {
                let fileName = imageURL.lastPathComponent
                self.saveImageLocally(data: imageData, with: fileName) { success, error in
                    completion(success ? image : nil, error)
                }
            } else {
                completion(image, nil)
            }
        }.resume()
    }
    
    // Helper function to save the image locally
    private func saveImageLocally(data: Data, with fileName: String, completion: @escaping (Bool, Error?) -> Void) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access document directory"]))
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
}


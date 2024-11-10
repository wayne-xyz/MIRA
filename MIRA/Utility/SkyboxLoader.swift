import Foundation


class SkyboxLoader {
    private let baseURL = "https://backend.blockadelabs.com/api/v1"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func requestExport(skyboxId: String, typeId: Int, webhookUrl: String? = nil, completion: @escaping (ExportResponse?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/skybox/export") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var parameters: [String: Any] = [
            "skybox_id": skyboxId,
            "type_id": typeId
        ]
        
        if let webhookUrl = webhookUrl {
            parameters["webhook_url"] = webhookUrl
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let exportResponse = try decoder.decode(ExportResponse.self, from: data)
                completion(exportResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func checkExportStatus(exportId: String, completion: @escaping (ExportResponse?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/skybox/export/\(exportId)") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let exportResponse = try decoder.decode(ExportResponse.self, from: data)
                completion(exportResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func cancelExport(exportId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/skybox/export/\(exportId)") else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Bool],
                   let success = json["success"] {
                    completion(success, nil)
                } else {
                    completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
            } catch {
                completion(false, error)
            }
        }.resume()
    }
}

// MARK: - Response Models
struct ExportResponse: Codable {
    let id: String
    let skyboxObfuscatedId: String
    let type: String
    let typeId: Int
    let status: String
    let queuePosition: Int
    let errorMessage: String?
    let pusherChannel: String
    let pusherEvent: String
    let fileUrl: String?
    let createdAt: String
}

// MARK: - Export Type IDs
enum SkyboxExportType: Int {
    case jpg = 1
    case png = 2
    case cubeMap = 3
    case hdriHdr = 4
    case hdriExr = 5
    case depthMap = 6
    case videoLandscape = 7
    case videoPortrait = 8
    case videoSquare = 9
}

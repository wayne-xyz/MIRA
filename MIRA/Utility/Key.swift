import Foundation

class Key {
    private(set) var apiKey: String = ""
    
    init(keyfilename: String) {
        loadKey(keyfilename: keyfilename)
    }
    
    private func loadKey(keyfilename: String) {
        guard let path = Bundle.main.path(forResource: keyfilename, ofType: nil) else {
            print("❌ No .env file found")
            return
        }
        
        do {
            // Read the content and trim whitespace/newlines
            let content = try String(contentsOfFile: path, encoding: .utf8)
            apiKey = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Verify key was loaded
            if !apiKey.isEmpty {
                print("✅ API key loaded successfully")
                // Optional: Print first few characters for verification
                let previewLength = min(apiKey.count, 4)
                let preview = String(apiKey.prefix(previewLength))
                print("Key preview: \(preview)...")
            } else {
                print("⚠️ API key is empty")
            }
            
        } catch {
            print("❌ Error loading API key: \(error)")
        }
    }
}


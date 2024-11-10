import Foundation
import Speech

class ConversationManager: NSObject, SFSpeechRecognizerDelegate,ObservableObject {
    let WINDOW_CONTEXT_TIME_INTERVAL = 20.0


    static let shared = ConversationManager()
    static let REQUIREMENT_GPT_PROMPT="Here is a part of conversation context based on that, please provide me 5 key words to summarize the context,only return the 5 words. "

    // creart a list of the string for listing keywords,will show on the ui
    public var keywords: [String] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var timer: Timer?
    private var windowStartTime: Date?
    private var windowContext: String = ""  // Current window context
    private var currentPartialResult: String = ""  // Current partial result
    
    private override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    func startRecording() throws {
        // Cancel any ongoing tasks
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "ConversationManagerErrorDomain", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let newText = result.bestTranscription.formattedString
                
                // Only add new text that wasn't in the previous partial result
                if newText.count > self.currentPartialResult.count {
                    let newContent = String(newText.suffix(from: newText.index(newText.startIndex, offsetBy: self.currentPartialResult.count)))
                    self.windowContext += newContent
                }
                self.currentPartialResult = newText
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start timer for periodic processing
        startPeriodicProcessing()
    }
    
    func stopRecording() {
        // Process any remaining context before stopping
        if !windowContext.isEmpty {
            updateKeywords(context: windowContext)
        }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        timer?.invalidate()
        timer = nil
        
        // Reset all window-related variables
        windowContext = ""
        currentPartialResult = ""
        windowStartTime = nil
    }
    
    private func startPeriodicProcessing() {
        timer?.invalidate()
        windowStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: WINDOW_CONTEXT_TIME_INTERVAL, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.performPeriodicProcessing()
        }
    }
    
    private func performPeriodicProcessing() {
        // Process the current window context
        updateKeywords(context: windowContext)
        
        // Reset for next window
        windowContext = ""
        currentPartialResult = ""
        windowStartTime = Date()
    }

    // private function to add keywords to the list
    private func addKeyword(keyword: String) {
        print("Keywords: \(keywords),\(String(describing: currentTimeStamp))")
        keywords.append(keyword)
    }
    
    private func currentTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    
    private func updateKeywords(context: String) {
        // Create DateFormatter for readable timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        print("Processing context: \(context), time: \(timestamp)")
        // Add your custom logic here
        NetworkManager.shared.sendChatGPTPrompt(context){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.addKeyword(keyword: response)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            
        }
        
    }
    
    // Handle authorization
    func requestSpeechAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
}

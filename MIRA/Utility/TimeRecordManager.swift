import Foundation

class TimeRecordManager {
    static let shared = TimeRecordManager()
    private let userDefaults = UserDefaults.standard
    private let timeRecordPrefix = "timeRecord_"
    
    private init() {}
    
    func saveTimeRecord(for key: String) {
        let currentTime = Date()
        userDefaults.set(currentTime, forKey: timeRecordPrefix + key)
        userDefaults.synchronize()
        print("Time record saved for key: \(key)")
    }
    
    func getTimeRecord(for key: String) -> Date? {
        print("Time record retrieved for key: \(key)")
        return userDefaults.object(forKey: timeRecordPrefix + key) as? Date
    }
} 
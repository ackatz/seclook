import Foundation

class ConfigManager {
    static let shared = ConfigManager()

    func setAPIKey(service: String, key: String) {
        UserDefaults.standard.set(key, forKey: service)
    }
    
    func getAPIKey(service: String) -> String? {
        UserDefaults.standard.string(forKey: service)
    }
    
    func setBool(for key: String, value: Bool) {
            UserDefaults.standard.set(value, forKey: key)
    }
        
    func getBool(for key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
}

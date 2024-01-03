import Foundation

class APIService {
    static func checkAbuseIPDB(ip: String, completion: @escaping (Bool) -> Void) {
        guard let apiKey = ConfigManager.shared.getAPIKey(service: "abuseipdb") else {
            print("API Key not set for AbuseIPDB")
            completion(false)
            return
        }
        
        // Check if apiKey length is exactly 80 characters
        guard apiKey.count == 80 else {
            print("API Key not set for AbuseIPDB")
            completion(false)
            return
        }
        
        let urlString = "https://api.abuseipdb.com/api/v2/check"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Key")
        request.httpMethod = "GET"
        
        let queryParams = ["ipAddress": ip, "maxAgeInDays": "90"]
        let queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        request.url = components?.url
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API call: \(error)")
                completion(false)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(AbuseIPDBResponse.self, from: data)
                if apiResponse.data.abuseConfidenceScore > 0 || apiResponse.data.isTor {
                    completion(true)  // IP is considered malicious
                    DispatchQueue.main.async {
                        postNotification(for: ip, type: "IP", source: "AbuseIPDB")
                    }
                } else {
                    completion(false) // IP is not considered malicious
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    static func checkVirusTotal(content: String, type: String, completion: @escaping (Bool) -> Void) {
        guard let apiKey = ConfigManager.shared.getAPIKey(service: "virustotal") else {
            print("API Key not set for VirusTotal")
            completion(false)
            return
        }
        
        // Check if apiKey length is exactly 64 characters
        guard apiKey.count == 64 else {
            print("API Key not set for VirusTotal")
            completion(false)
            return
        }
        
        // Don't check your own key in VT :O)
        if apiKey == content {
            return
        }
        
        
        let baseUrl = "https://www.virustotal.com/api/v3"
        var endpoint = ""
        
        switch type {
        case "IP":
            endpoint = "/ip_addresses/\(content)"
        case "Domain":
            endpoint = "/domains/\(content)"
        case "SHA256", "MD5":
            endpoint = "/files/\(content)"
        default:
            print("Invalid content type for VirusTotal check")
            completion(false)
            return
        }
        
        guard let url = URL(string: baseUrl + endpoint) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("\(apiKey)", forHTTPHeaderField: "X-Apikey") // Corrected format
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API call: \(error)")
                completion(false)
                return
            }
            
            // Print response for debugging
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data from VirusTotal: \(dataString)")
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(VirusTotalResponse.self, from: data)
                let stats = apiResponse.data.attributes.last_analysis_stats
                if stats.malicious > 0 || stats.suspicious > 0 {
                    DispatchQueue.main.async {
                        postNotification(for: content, type: type, source: "VirusTotal")
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
}

struct VirusTotalResponse: Codable {
    struct Data: Codable {
        struct Attributes: Codable {
            struct AnalysisStats: Codable {
                let harmless: Int
                let malicious: Int
                let suspicious: Int
                let undetected: Int
                let timeout: Int
            }
            let last_analysis_stats: AnalysisStats
        }
        let attributes: Attributes
    }
    let data: Data
}

struct AbuseIPDBResponse: Codable {
    struct Data: Codable {
        let abuseConfidenceScore: Int
        let isTor: Bool
    }
    let data: Data
}

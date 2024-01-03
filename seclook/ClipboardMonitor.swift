import AppKit

class ClipboardMonitor: ObservableObject {
    
    // Set ConcealedTypeIdentifier for ignoring confidential information
    private let ConcealedTypeIdentifier = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
    
    private let maxClipboardSize = 1000
    private var timer: Timer?
    private var lastCheckedItem: String = ""
    @Published var lastScannedItem: String = ""
    var ignoreListManager: IgnoreListManager
    
    init(ignoreListManager: IgnoreListManager) {
        self.ignoreListManager = ignoreListManager
        startMonitoring()
    }
    
    
    func startMonitoring() {
        if timer != nil {
            print("Attempted to start monitoring, but it's already running.")
            return
        }

        print("Starting Clipboard Monitoring")
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }


    func stopMonitoring() {
        print("Stopping Clipboard Monitoring")
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let checkIP = UserDefaults.standard.bool(forKey: "checkIP")
        let checkSHA256 = UserDefaults.standard.bool(forKey: "checkSHA256")
        let checkMD5 = UserDefaults.standard.bool(forKey: "checkMD5")
        let checkDomain = UserDefaults.standard.bool(forKey: "checkDomain")
        
        let pasteboard = NSPasteboard.general
        
        // Check for Concealed Type
        if pasteboard.types?.contains(ConcealedTypeIdentifier) == true {
            print("Ignored clipboard content from Concealed Type")
            return
        }
        
        if let currentClipboardContent = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if currentClipboardContent.count > maxClipboardSize {
                return
            }

            let (matchedContent, contentType) = determineContentType(currentClipboardContent)
            let itemWithContentType = "\(matchedContent) [\(contentType)]"

            if matchedContent != lastCheckedItem {
                if ignoreListManager.ignoreList.contains(itemWithContentType) {
                    print("\(itemWithContentType) is in the ignore list and will be ignored.")
                    return
                }

                switch contentType {
                case "IP":
                    if checkIP {
                        APIService.checkAbuseIPDB(ip: matchedContent) { _ in }
                        APIService.checkVirusTotal(content: matchedContent, type: "IP") { _ in }

                        lastCheckedItem = matchedContent
                        self.lastScannedItem = itemWithContentType
                    }

                case "Domain":
                    if checkDomain {
                        APIService.checkVirusTotal(content: matchedContent, type: "Domain") { _ in }
                    
                        lastCheckedItem = matchedContent
                        self.lastScannedItem = itemWithContentType
                    }

                case "SHA256":
                    if checkSHA256 {
                        APIService.checkVirusTotal(content: matchedContent, type: "SHA256") { _ in }
                    
                        lastCheckedItem = matchedContent
                        self.lastScannedItem = itemWithContentType
                    }

                case "MD5":
                    if checkMD5 {
                        APIService.checkVirusTotal(content: matchedContent, type: "MD5") { _ in }

                        lastCheckedItem = matchedContent
                        self.lastScannedItem = itemWithContentType
                    }

                default:
                    print("Unknown content type")
                    // Do not update lastScannedItem for unknown content types
                }
            } else {
                print("Clipboard content has not changed and will be ignored.")
            }
        } else {
            print("No valid string content in clipboard or content is empty.")
        }
    }


    private func isIPAddress(_ string: String) -> String? {
        let ipRegex = "(?!(?:127\\.0\\.0\\.1|10(?:\\.\\d{1,3}){3}|172\\.(?:1[6-9]|2\\d|3[01])(?:\\.\\d{1,3}){2}|192\\.168(?:\\.\\d{1,3}){2}))(?:[1-9]\\d?|1\\d{2}|2[0-4]\\d|25[0-5])\\.(?:[1-9]\\d?|1\\d{2}|2[0-4]\\d|25[0-5])\\.(?:[1-9]\\d?|1\\d{2}|2[0-4]\\d|25[0-5])\\.(?!0\\b)(?:[1-9]\\d?|1\\d{2}|2[0-4]\\d|25[0-5])"
           do {
               let regex = try NSRegularExpression(pattern: ipRegex)
               let nsrange = NSRange(string.startIndex..<string.endIndex, in: string)
               if let match = regex.firstMatch(in: string, options: [], range: nsrange) {
                   let ipRange = Range(match.range, in: string)!
                   return String(string[ipRange])
               }
           } catch {
               print("Invalid regex: \(error.localizedDescription)")
           }
           return nil
       }

       private func isSHA256Hash(_ string: String) -> String? {
           let sha256Regex = "[A-Fa-f0-9]{64}"
           
           do {
               let regex = try NSRegularExpression(pattern: sha256Regex)
               let nsrange = NSRange(string.startIndex..<string.endIndex, in: string)
               if let match = regex.firstMatch(in: string, options: [], range: nsrange) {
                   let sha256Range = Range(match.range, in: string)!
                   return String(string[sha256Range])
               }
           } catch {
               print("Invalid regex: \(error.localizedDescription)")
           }
           return nil
       }

       private func isMD5Hash(_ string: String) -> String? {
           let md5Regex = "[A-Fa-f0-9]{32}"
           
           do {
               let regex = try NSRegularExpression(pattern: md5Regex)
               let nsrange = NSRange(string.startIndex..<string.endIndex, in: string)
               if let match = regex.firstMatch(in: string, options: [], range: nsrange) {
                   let md5Range = Range(match.range, in: string)!
                   return String(string[md5Range])
               }
           } catch {
               print("Invalid regex: \(error.localizedDescription)")
           }
           return nil
       }

       private func isDomain(_ string: String) -> String? {
           let domainRegex = "https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
           
           do {
               let regex = try NSRegularExpression(pattern: domainRegex)
               let nsrange = NSRange(string.startIndex..<string.endIndex, in: string)
               if let match = regex.firstMatch(in: string, options: [], range: nsrange) {
                   let domainRange = Range(match.range, in: string)!
                   return String(string[domainRange])
               }
           } catch {
               print("Invalid regex: \(error.localizedDescription)")
           }
           return nil
       }
    
    private func determineContentType(_ string: String) -> (String, String) {
        let checkIP = UserDefaults.standard.bool(forKey: "checkIP")
            let checkSHA256 = UserDefaults.standard.bool(forKey: "checkSHA256")
            let checkMD5 = UserDefaults.standard.bool(forKey: "checkMD5")
            let checkDomain = UserDefaults.standard.bool(forKey: "checkDomain")

            // Prioritize checking based on user preferences
            if checkIP, let ip = isIPAddress(string) {
                return (ip, "IP")
            }
        
            if checkSHA256, let sha256 = isSHA256Hash(string) {
                return (sha256, "SHA256")
            }
        
            if checkMD5, let md5 = isMD5Hash(string) {
                return (md5, "MD5")
            }
        
            if checkDomain, let domain = isDomain(string) {
                return (domain, "Domain")
            }
        
        return (string, "Unknown")
    }
    
}

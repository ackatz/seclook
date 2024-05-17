import Foundation
import UserNotifications

func postNotification(for item: String, type: String, source: String) {
    print("Posting notification for \(item) from \(source)")
    let notificationContent = UNMutableNotificationContent()
    notificationContent.sound = UNNotificationSound.default

    switch source {
        case "AbuseIPDB":
            notificationContent.title = "Security Alert from AbuseIPDB"
            notificationContent.body = "The \(type) \(item) is potentially malicious according to AbuseIPDB."
        case "VirusTotal":
            notificationContent.title = "Security Alert from VirusTotal"
            notificationContent.body = "The \(type) \(item) is potentially malicious according to VirusTotal."
        case "ThreatFox":
            notificationContent.title = "Security Alert from ThreatFox"
            notificationContent.body = "The \(type) \(item) is potentially malicious according to ThreatFox."
        case "GreyNoise":
            notificationContent.title = "Security Alert from GreyNoise"
            notificationContent.body = "The \(type) \(item) is potentially malicious according to GreyNoise."
        default:
            notificationContent.title = "Security Alert"
            notificationContent.body = "The \(type) \(item) is potentially malicious."
        }

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}

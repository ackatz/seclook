import SwiftUI

struct ConfigurationView: View {
    @State private var abuseIPDBKey: String = ""
    @State private var VirusTotalKey: String = ""

    var body: some View {
        Form {
            Section(header: Text("API Keys")) {
                TextField("AbuseIPDB Key", text: $abuseIPDBKey)
                TextField("VirusTotal Key", text: $VirusTotalKey)

                Button("Save") {
                    ConfigManager.shared.setAPIKey(service: "abuseipdb", key: abuseIPDBKey)
                    ConfigManager.shared.setAPIKey(service: "virustotal", key: VirusTotalKey)
                }
            }
        }
        .onAppear {
            // Load previously saved keys
            abuseIPDBKey = ConfigManager.shared.getAPIKey(service: "abuseipdb") ?? ""
            VirusTotalKey = ConfigManager.shared.getAPIKey(service: "virustotal") ?? ""
        }
    }
}


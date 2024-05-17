import SwiftUI

struct ConfigurationView: View {
    @State private var abuseIPDBKey: String = ""
    @State private var VirusTotalKey: String = ""
    @State private var ThreatFoxKey: String = ""
    @State private var GreyNoiseKey: String = ""

    var body: some View {
        Form {
            Section(header: Text("API Keys")) {
                TextField("AbuseIPDB Key", text: $abuseIPDBKey)
                TextField("VirusTotal Key", text: $VirusTotalKey)
                TextField("ThreatFox Key", text: $ThreatFoxKey)
                TextField("GreyNoise Key", text: $GreyNoiseKey)

                Button("Save") {
                    ConfigManager.shared.setAPIKey(service: "abuseipdb", key: abuseIPDBKey)
                    ConfigManager.shared.setAPIKey(service: "virustotal", key: VirusTotalKey)
                    ConfigManager.shared.setAPIKey(service: "threatfox", key: ThreatFoxKey)
                    ConfigManager.shared.setAPIKey(service: "greynoise", key: GreyNoiseKey)
                }
            }
        }
        .onAppear {
            // Load previously saved keys
            abuseIPDBKey = ConfigManager.shared.getAPIKey(service: "abuseipdb") ?? ""
            VirusTotalKey = ConfigManager.shared.getAPIKey(service: "virustotal") ?? ""
            ThreatFoxKey = ConfigManager.shared.getAPIKey(service: "threatfox") ?? ""
            GreyNoiseKey = ConfigManager.shared.getAPIKey(service: "greynoise") ?? ""
        }
    }
}


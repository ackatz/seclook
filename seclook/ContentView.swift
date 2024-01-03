import SwiftUI

struct ContentView: View {
    
    // State variables for expanded/collapsed state of each DisclosureGroup
    @State private var isIgnoredItemsExpanded = false
    @State private var isAPIKeysExpanded = false
    @State private var isSettingsExpanded = false
    
    private func clearAllSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Reset IgnoreListManager
        ignoreListManager.resetToDefaultIgnoreItems()

        // Resetting the state variables to reflect the cleared settings
        abuseIPDBKey = ""
        VirusTotalKey = ""
        checkIP = false
        checkSHA256 = false
        checkMD5 = false
        checkDomain = false
    }
    
    
    
    // State variables to store the toggle states for each type of regex check
    @State private var checkIP: Bool
    @State private var checkSHA256: Bool
    @State private var checkMD5: Bool
    @State private var checkDomain: Bool

    @ObservedObject var ignoreListManager: IgnoreListManager
    @ObservedObject var clipboardMonitor: ClipboardMonitor

    // Properties for API keys
    @State private var abuseIPDBKey: String = ""
    @State private var VirusTotalKey: String = ""
    // Add more @State properties for other API keys as needed

    init(clipboardMonitor: ClipboardMonitor) {
        self.clipboardMonitor = clipboardMonitor
        ignoreListManager = IgnoreListManager.shared

        // Check if 'isFirstRun' key exists
        if UserDefaults.standard.object(forKey: "isFirstRun") == nil {
            
            // This means it's the first run
            _checkIP = State(initialValue: true)
            _checkSHA256 = State(initialValue: false)
            _checkMD5 = State(initialValue: false)
            _checkDomain = State(initialValue: false)

            // Save these settings
            ConfigManager.shared.setBool(for: "checkIP", value: true)
            ConfigManager.shared.setBool(for: "checkSHA256", value: false)
            ConfigManager.shared.setBool(for: "checkMD5", value: false)
            ConfigManager.shared.setBool(for: "checkDomain", value: false)
            
            // Set default ignorelist items
            ignoreListManager.resetToDefaultIgnoreItems()
            
            // Set 'isFirstRun' to false
            UserDefaults.standard.set(false, forKey: "isFirstRun")
        } else {
            // Not the first run, so initialize from UserDefaults
            _checkIP = State(initialValue: ConfigManager.shared.getBool(for: "checkIP"))
            _checkSHA256 = State(initialValue: ConfigManager.shared.getBool(for: "checkSHA256"))
            _checkMD5 = State(initialValue: ConfigManager.shared.getBool(for: "checkMD5"))
            _checkDomain = State(initialValue: ConfigManager.shared.getBool(for: "checkDomain"))
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Section with app name and description
            Text("seclook")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.white)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Automatic security lookups from your clipboard")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center)

            // Display the last scanned item or a placeholder
            if !clipboardMonitor.lastScannedItem.isEmpty {
                scannedItemSection
            } else {
                Text("No recent scans")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
            }

            Divider().background(Color.gray)

            // ScrollView for Ignored Items, Settings, and API Keys Configuration
            ScrollView {
                // Ignored Items Section
                DisclosureGroup(
                    isExpanded: $isIgnoredItemsExpanded,
                    content: {
                                  ForEach(ignoreListManager.ignoreList, id: \.self) { item in
                                      HStack {
                                          Text(item)
                                              .foregroundColor(.white)
                                          Spacer()
                                          removeButton(for: item)
                                      }
                                  }
                              },
                    label: {
                        Button(action: {
                            self.isIgnoredItemsExpanded.toggle()
                        }) {
                            HStack {
                                Text("📃 Ignored Items")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                               
                            }
                            .background(Color.clear)
                        }.accessibilityIdentifier("IgnoredItemsButton")
                        .buttonStyle(PlainButtonStyle())
                    }
                )
                .padding()
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .shadow(radius: 2)
                .background(Color.clear)

                // API Keys Configuration Section
                DisclosureGroup(
                    isExpanded: $isAPIKeysExpanded,
                    content: {
                        VStack {
                            //
                            Text("AbuseIPDB Key")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                    
                            SecureField("Enter AbuseIPDB Key", text: $abuseIPDBKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.black)
                

                            //
                            Text("VirusTotal Key")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                  
                            SecureField("Enter VirusTotal Key", text: $VirusTotalKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.black)
    
                            Button("Save") {
                                ConfigManager.shared.setAPIKey(service: "abuseipdb", key: abuseIPDBKey)
                                ConfigManager.shared.setAPIKey(service: "virustotal", key: VirusTotalKey)
                            }
                            .buttonStyle(ModernButtonStyle(backgroundColor: Color.blue))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    },
                    label: {
                        Button(action: {
                            self.isAPIKeysExpanded.toggle()
                        }) {
                            HStack {
                                Text("🔐 API Keys Configuration")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }.accessibilityIdentifier("APIKeysButton")
                            .background(Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    
                    
                )
                
                .padding()
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Settings Section
                            DisclosureGroup(
                                isExpanded: $isSettingsExpanded,
                                content: {
                                    Text("String types to check")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding([.top, .leading], 16.0)
                                    
                                    Toggle("IP Address", isOn: Binding<Bool>(
                                        get: { self.checkIP },
                                        set: { newValue in
                                            self.checkIP = newValue
                                            ConfigManager.shared.setBool(for: "checkIP", value: newValue)
                                            print("IP Address toggle set to: \(newValue)")
                                        }
                                    ))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16.0)
                                    
                                    Toggle("SHA256 Hash", isOn: Binding<Bool>(
                                        get: { self.checkSHA256 },
                                        set: { newValue in
                                            self.checkSHA256 = newValue
                                            ConfigManager.shared.setBool(for: "checkSHA256", value: newValue)
                                            print("SHA256 toggle set to: \(newValue)")
                                        }
                                    ))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16.0)
                                    
                                    Toggle("MD5 Hash", isOn: Binding<Bool>(
                                        get: { self.checkMD5 },
                                        set: { newValue in
                                            self.checkMD5 = newValue
                                            ConfigManager.shared.setBool(for: "checkMD5", value: newValue)
                                            print("MD5 toggle set to: \(newValue)")
                                        }
                                    ))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16.0)
                                    
                                    Toggle("Domain", isOn: Binding<Bool>(
                                        get: { self.checkDomain },
                                        set: { newValue in
                                            self.checkDomain = newValue
                                            ConfigManager.shared.setBool(for: "checkDomain", value: newValue)
                                            print("Domain toggle set to: \(newValue)")
                                        }
                                    ))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16.0)
                                    Button("Clear All Settings") {
                                                self.clearAllSettings()
                                            }
                                            .buttonStyle(ModernButtonStyle(backgroundColor: Color.red))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding([.top, .leading], 16.0)
                                },
                                
                                label: {
                                    Button(action: {
                                        self.isSettingsExpanded.toggle()
                                    }) {
                                        HStack {
                                            Text("⚙️ Settings")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Spacer()
                                           
                                        }.accessibilityIdentifier("SettingsButton")
                                        .background(Color.clear)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            )
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .foregroundColor(.white)
                
                .foregroundColor(.white)
                
              }
            
            
        
          .frame(maxHeight: .infinity)
        
            Spacer()
            
            HStack {
                            // About/Docs Link
                            Link("Homepage 🔗", destination: URL(string: "https://seclook.app")!)
                            .frame(maxWidth: .infinity, alignment: .center)

                            Spacer()

                            // Contribute Link
                            Link("Contribute 🌟", destination: URL(string: "https://github.com/ackatz/seclook")!)
                    .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .padding(.bottom, 20)
                    
        }
        
        .padding(0)
        .background(Color(red: 0.11764705882352941, green: 0.11764705882352941, blue: 0.11764705882352941))
        .onAppear {
            // Load the API keys when the view appears
            print("ContentView loaded. Last scanned item: \(clipboardMonitor.lastScannedItem)")
            abuseIPDBKey = ConfigManager.shared.getAPIKey(service: "abuseipdb") ?? ""
            VirusTotalKey = ConfigManager.shared.getAPIKey(service: "virustotal") ?? ""
            checkIP = ConfigManager.shared.getBool(for: "checkIP")
            checkSHA256 = ConfigManager.shared.getBool(for: "checkSHA256")
            checkMD5 = ConfigManager.shared.getBool(for: "checkMD5")
            checkDomain = ConfigManager.shared.getBool(for: "checkDomain")
        }
    }
    

    private var scannedItemSection: some View {
        VStack {
            Text("Last Scanned:")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(clipboardMonitor.lastScannedItem)
                .padding(.all, 10)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
            
            Button("Ignore") {
                let components = clipboardMonitor.lastScannedItem.split(separator: " [")
                let item = String(components[0])
                let type = components.count > 1 ? String(components[1].dropLast()) : "Unknown"
                ignoreListManager.addToIgnoreList(item: item, type: type)
            }
            .buttonStyle(ModernButtonStyle(backgroundColor: Color.blue))
        }
    }

    private func removeButton(for item: String) -> some View {
        Button("Remove") {
            ignoreListManager.removeFromIgnoreList(item: item)
        }
        .buttonStyle(ModernButtonStyle(backgroundColor: Color.blue))
    }
    
}

struct ModernButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    var backgroundColor: Color = .gray

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .shadow(radius: 1)
    }
}

extension ClipboardMonitor {
    static var mock: ClipboardMonitor {
        let mockMonitor = ClipboardMonitor(ignoreListManager: IgnoreListManager.shared)
        return mockMonitor
    }
}


// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(clipboardMonitor: ClipboardMonitor.mock)
    }
}

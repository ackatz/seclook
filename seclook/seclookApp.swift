import SwiftUI
import AppKit
import UserNotifications
import Sparkle

// Main entry point for the SwiftUI app
@main
struct seclookApp: App {
    private let updaterController: SPUStandardUpdaterController
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(clipboardMonitor: appDelegate.clipboardMonitor)
                .frame(minWidth: 400, minHeight: 500)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            SidebarCommands()
        }
    }
}

// This view model class publishes when new updates can be checked by the user
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater
    
    init(updater: SPUUpdater) {
        self.updater = updater
        
        // Create our view model for our CheckForUpdatesView
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }
    
    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusBar: StatusBarController?
    var isAppActive: Bool = true
    var clipboardMonitor: ClipboardMonitor
    
    override init() {
          let ignoreListManager = IgnoreListManager.shared
          clipboardMonitor = ClipboardMonitor(ignoreListManager: ignoreListManager)
          super.init()
      }

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification Permission Error: \(error)")
            } else if granted {
                print("Notification permission granted.")
            }
        }
    
        
        clipboardMonitor.startMonitoring()
        statusBar = StatusBarController(initiallyActive: isAppActive) {
            self.toggleApp()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.banner, .sound])
     }
    
    func toggleApp() {
        isAppActive.toggle()
        if isAppActive {
            clipboardMonitor.startMonitoring()
        } else {
            clipboardMonitor.stopMonitoring()
        }
    }
}


// StatusBarController class for managing the status bar item
class StatusBarController {
    private var statusBar: NSStatusItem
    private var menu: NSMenu
    var toggleAction: () -> Void

    init(initiallyActive: Bool, toggleAction: @escaping () -> Void) {
        self.toggleAction = toggleAction
        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu = NSMenu()

        if let button = statusBar.button {
            button.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "seclook")
        }
        
        // Add a non-selectable title item for "seclook"
        let titleItem = NSMenuItem(title: "seclook", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false // Disable the item to make it greyed-out
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // Toggle item for turning on/off
        let toggleItem = NSMenuItem(title: initiallyActive ? "Turn Off" : "Turn On", action: #selector(toggleAppStatus), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        statusBar.menu = menu
    }
    
    @objc func toggleAppStatus() {
        toggleAction()
        
        if let toggleItem = menu.items.first(where: { $0.action == #selector(toggleAppStatus) }) {
            toggleItem.title = toggleItem.title == "Turn Off" ? "Turn On" : "Turn Off"
        }
    }
}

extension seclookApp {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle the permission granted status
            if let error = error {
                print("Notification Permission Error: \(error)")
            }
        }
    }
}

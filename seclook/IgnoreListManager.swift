import Foundation

class IgnoreListManager: ObservableObject {
    static let shared = IgnoreListManager()
    @Published var ignoreList: [String] = []
    
    func resetToDefaultIgnoreItems() {
        ignoreList = [
            "1.1.1.1 [IP]",
            "8.8.8.8 [IP]",
            "8.8.4.4 [IP]",
            "9.9.9.9 [IP]",
            "https://github.com [Domain]",
            "https://google.com [Domain]",
            "https://facebook.com [Domain]",
            "https://youtube.com [Domain]",
            "https://amazon.com [Domain]",
            "https://wikipedia.org [Domain]",
            "https://twitter.com [Domain]",
            "https://bing.com [Domain]",
            "https://reddit.com [Domain]",
            "https://linkedin.com [Domain]",
            "https://instagram.com [Domain]"
        ]
            saveIgnoreList()
        }
    
    private init() {
        let isFirstRun = UserDefaults.standard.bool(forKey: "isFirstRun")
        if isFirstRun {
            // Set default ignore items
            ignoreList = [
                "1.1.1.1 [IP]",
                "8.8.8.8 [IP]",
                "8.8.4.4 [IP]",
                "9.9.9.9 [IP]",
                "https://github.com [Domain]",
                "https://google.com [Domain]",
                "https://facebook.com [Domain]",
                "https://youtube.com [Domain]",
                "https://amazon.com [Domain]",
                "https://wikipedia.org [Domain]",
                "https://twitter.com [Domain]",
                "https://bing.com [Domain]",
                "https://reddit.com [Domain]",
                "https://linkedin.com [Domain]",
                "https://instagram.com [Domain]"
            ]

            saveIgnoreList()
            UserDefaults.standard.set(false, forKey: "isFirstRun")
        } else {
            loadIgnoreList()
        }
    }

    
    private func loadIgnoreList() {
         if let savedItems = UserDefaults.standard.array(forKey: "IgnoreList") as? [String] {
             ignoreList = savedItems
             print("List reloaded")
         }
     }

    
    func saveIgnoreList() {
        UserDefaults.standard.set(ignoreList, forKey: "IgnoreList")
    }
    
    
    func addToIgnoreList(item: String, type: String) {
        let itemWithType = "\(item) [\(type)]"
        if !ignoreList.contains(itemWithType) {
            ignoreList.append(itemWithType)
            saveIgnoreList()
        }
        loadIgnoreList()
    }
    
    func removeFromIgnoreList(item: String) {
        if let index = ignoreList.firstIndex(of: item) {
            ignoreList.remove(at: index)
            saveIgnoreList()
            loadIgnoreList() // Reload the list after saving
        }
    }
}

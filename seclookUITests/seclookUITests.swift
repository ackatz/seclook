import XCTest

final class seclookUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }
    
    func testBasicTextElementsExist() {
        // 1
        let app = XCUIApplication()
        
        // 2
        let window = app.windows
        
        // 3
        XCTAssertTrue(window.staticTexts["seclook"].exists, "Seclook header should exist")
        
        // 4
        XCTAssertTrue(window.staticTexts["Automatic security lookups from your clipboard"].exists, "Seclook header2 should exist")
        
        // 5
        XCTAssertTrue(window.staticTexts["No recent scans"].exists, "It should say no recent scans when started")
        
        // 6
        XCTAssertTrue(window.links["Homepage 🔗"].exists, "Homepage link should exist")
        
        // 6
        XCTAssertTrue(window.links["Contribute 🌟"].exists, "Contribute link should exist")
    }
    
    func testDisclosureGroups() {
        let app = XCUIApplication()

        // Test Ignored Items Disclosure Group
        let ignoredItemsButton = app.buttons["IgnoredItemsButton"]
        if ignoredItemsButton.exists {
            ignoredItemsButton.tap() // Expand the group
            // Assertions for Ignored Items content
            XCTAssertTrue(app.textFields["IgnoreListTextField"].exists, "Ignore list text field should exist")
            XCTAssertTrue(app.buttons["RemoveIgnoreItemButton"].exists, "Remove button for ignore items should exist")
        }

        // Test API Keys Configuration Disclosure Group
        let apiKeysButton = app.buttons["APIKeysButton"]
        if apiKeysButton.exists {
            apiKeysButton.tap() // Expand the group
            // Assertions for API Keys content
            XCTAssertTrue(app.secureTextFields["AbuseIPDBKeyTextField"].exists, "AbuseIPDB key securetext field should exist")
            XCTAssertTrue(app.secureTextFields["VirusTotalKeyTextField"].exists, "VirusTotal key securetext field should exist")
            XCTAssertTrue(app.buttons["SaveAPIKeysButton"].exists, "Save API keys button should exist")
        }

        // Test Settings Disclosure Group
        let settingsButton = app.buttons["SettingsButton"]
        if settingsButton.exists {
            settingsButton.tap() // Expand the group
            // Assertions for Settings content
            XCTAssertTrue(app.switches["CheckIPSwitch"].exists, "IP Address check toggle should exist")
            XCTAssertTrue(app.switches["CheckSHA256Switch"].exists, "SHA256 check toggle should exist")
            XCTAssertTrue(app.switches["CheckMD5Switch"].exists, "MD5 check toggle should exist")
            XCTAssertTrue(app.switches["CheckDomainSwitch"].exists, "Domain check toggle should exist")
            XCTAssertTrue(app.buttons["ClearSettingsButton"].exists, "Clear settings button should exist")
        }
    }

}

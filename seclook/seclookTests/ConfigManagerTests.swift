import XCTest
@testable import seclook


class ConfigManagerTests: XCTestCase {
    var configManager: ConfigManager!

    override func setUpWithError() throws {
        configManager = ConfigManager.shared
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    func testSetAndGetAPIKey() {
        let testKey = "testAPIKey"
        configManager.setAPIKey(service: "testService", key: testKey)
        XCTAssertEqual(configManager.getAPIKey(service: "testService"), testKey)
    }

    func testSetAndGetBool() {
        configManager.setBool(for: "testBool", value: true)
        XCTAssertTrue(configManager.getBool(for: "testBool"))
    }

}

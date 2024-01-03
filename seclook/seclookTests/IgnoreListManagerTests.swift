import XCTest

@testable import seclook

class IgnoreListManagerTests: XCTestCase {
    var ignoreListManager: IgnoreListManager!

    override func setUpWithError() throws {
        ignoreListManager = IgnoreListManager.shared
        ignoreListManager.ignoreList.removeAll()
    }

    func testAddToIgnoreList() {
        let item = "test.com [Domain]"
        ignoreListManager.addToIgnoreList(item: "test.com", type: "Domain")
        XCTAssertTrue(ignoreListManager.ignoreList.contains(item))
    }

    func testRemoveFromIgnoreList() {
        let item = "test.com [Domain]"
        ignoreListManager.addToIgnoreList(item: "test.com", type: "Domain")
        ignoreListManager.removeFromIgnoreList(item: item)
        XCTAssertFalse(ignoreListManager.ignoreList.contains(item))
    }
}

import XCTest
@testable import CrossTrack

final class VisitorIdManagerTests: XCTestCase {

    func testGeneratesVisitorId() {
        let storage = FakeStorage()
        let manager = VisitorIdManager(storage: storage)
        let id = manager.getVisitorId()
        XCTAssertFalse(id.isEmpty)
    }

    func testReturnsSameIdOnSubsequentCalls() {
        let storage = FakeStorage()
        let manager = VisitorIdManager(storage: storage)
        let id1 = manager.getVisitorId()
        let id2 = manager.getVisitorId()
        XCTAssertEqual(id1, id2)
    }

    func testPersistsAcrossInstances() {
        let storage = FakeStorage()
        let id1 = VisitorIdManager(storage: storage).getVisitorId()
        let id2 = VisitorIdManager(storage: storage).getVisitorId()
        XCTAssertEqual(id1, id2)
    }

    func testResetGeneratesNewId() {
        let storage = FakeStorage()
        let manager = VisitorIdManager(storage: storage)
        let id1 = manager.getVisitorId()
        manager.reset()
        let id2 = manager.getVisitorId()
        XCTAssertNotEqual(id1, id2)
    }
}

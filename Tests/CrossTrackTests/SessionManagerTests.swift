import XCTest
@testable import CrossTrack

final class SessionManagerTests: XCTestCase {

    func testGeneratesSessionId() {
        let storage = FakeStorage()
        let manager = SessionManager(storage: storage)
        let id = manager.getSessionId()
        XCTAssertFalse(id.isEmpty)
    }

    func testReturnsSameIdWithinTimeout() {
        let storage = FakeStorage()
        let manager = SessionManager(storage: storage, sessionTimeoutMs: 30 * 60 * 1000)
        let id1 = manager.getSessionId()
        let id2 = manager.getSessionId()
        XCTAssertEqual(id1, id2)
    }

    func testGeneratesNewIdAfterTimeout() {
        let storage = FakeStorage()
        let manager = SessionManager(storage: storage, sessionTimeoutMs: 1)
        let id1 = manager.getSessionId()
        Thread.sleep(forTimeInterval: 0.01)
        let id2 = manager.getSessionId()
        XCTAssertNotEqual(id1, id2)
    }

    func testResetClearsSession() {
        let storage = FakeStorage()
        let manager = SessionManager(storage: storage)
        let id1 = manager.getSessionId()
        manager.reset()
        let id2 = manager.getSessionId()
        XCTAssertNotEqual(id1, id2)
    }
}

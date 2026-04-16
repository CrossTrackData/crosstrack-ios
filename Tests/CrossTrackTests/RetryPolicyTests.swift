import XCTest
@testable import CrossTrack

final class RetryPolicyTests: XCTestCase {

    func testExponentialBackoff() {
        let policy = RetryPolicy(maxRetries: 5, baseDelayMs: 1000, maxDelayMs: 60000)
        XCTAssertEqual(policy.delay(for: 0), 1.0, accuracy: 0.001)
        XCTAssertEqual(policy.delay(for: 1), 2.0, accuracy: 0.001)
        XCTAssertEqual(policy.delay(for: 2), 4.0, accuracy: 0.001)
        XCTAssertEqual(policy.delay(for: 3), 8.0, accuracy: 0.001)
    }

    func testMaxDelayCap() {
        let policy = RetryPolicy(maxRetries: 10, baseDelayMs: 1000, maxDelayMs: 10000)
        XCTAssertEqual(policy.delay(for: 5), 10.0, accuracy: 0.001) // 32s capped to 10s
    }
}

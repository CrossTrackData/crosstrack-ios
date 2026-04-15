import XCTest
@testable import CrossTrack

final class EventTests: XCTestCase {

    func testEventSerialization() throws {
        let event = Event(
            eventId: "test-id",
            anonymousId: "visitor-1",
            userId: "john",
            type: "page_view",
            properties: ["url": "/pricing", "count": 42],
            context: EventContext(bridgeId: "bridge-1", sessionId: "session-1")
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["eventId"] as? String, "test-id")
        XCTAssertEqual(dict["anonymousId"] as? String, "visitor-1")
        XCTAssertEqual(dict["userId"] as? String, "john")
        XCTAssertEqual(dict["type"] as? String, "page_view")

        let context = dict["context"] as! [String: Any]
        XCTAssertEqual(context["platform"] as? String, "ios")
        XCTAssertEqual(context["bridgeId"] as? String, "bridge-1")
        XCTAssertEqual(context["sessionId"] as? String, "session-1")

        let properties = dict["properties"] as! [String: Any]
        XCTAssertEqual(properties["url"] as? String, "/pricing")
        XCTAssertEqual(properties["count"] as? Int, 42)
    }

    func testEventWithoutOptionalFields() throws {
        let event = Event(
            anonymousId: "visitor-1",
            type: "screen_view",
            context: EventContext(sessionId: "s1")
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(event)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertNil(dict["userId"])
        XCTAssertFalse(event.eventId.isEmpty)

        let context = dict["context"] as! [String: Any]
        XCTAssertNil(context["bridgeId"])
    }
}

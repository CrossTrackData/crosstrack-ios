import XCTest
@testable import CrossTrack

final class ConsentApiImplTests: XCTestCase {

    private func makeConsentApi() -> (ConsentApiImpl, EventQueue, VisitorIdManager) {
        let storage = FakeStorage()
        let apiClient = ApiClient(baseUrl: "https://localhost", apiKey: "test")
        let queue = EventQueue(apiClient: apiClient)
        let visitorIdManager = VisitorIdManager(storage: storage)
        let consent = ConsentApiImpl(storage: storage, eventQueue: queue, visitorIdManager: visitorIdManager)
        return (consent, queue, visitorIdManager)
    }

    func testDefaultConsentIsNotSet() {
        let (consent, _, _) = makeConsentApi()
        XCTAssertEqual(consent.getConsent(), .notSet)
    }

    func testOptIn() {
        let (consent, _, _) = makeConsentApi()
        consent.optIn()
        XCTAssertEqual(consent.getConsent(), .optedIn)
    }

    func testOptOut() {
        let (consent, _, _) = makeConsentApi()
        consent.optIn()
        consent.optOut()
        XCTAssertEqual(consent.getConsent(), .optedOut)
    }

    func testSetConsentPersists() {
        let storage = FakeStorage()
        let apiClient = ApiClient(baseUrl: "https://localhost", apiKey: "test")
        let queue = EventQueue(apiClient: apiClient)
        let visitorIdManager = VisitorIdManager(storage: storage)

        let consent1 = ConsentApiImpl(storage: storage, eventQueue: queue, visitorIdManager: visitorIdManager)
        consent1.setConsent(.optedIn)

        let consent2 = ConsentApiImpl(storage: storage, eventQueue: queue, visitorIdManager: visitorIdManager)
        XCTAssertEqual(consent2.getConsent(), .optedIn)
    }

    func testOptOutClearsQueue() {
        let (consent, queue, _) = makeConsentApi()
        consent.optIn()

        let event = Event(
            anonymousId: "test",
            type: "test",
            context: EventContext(sessionId: "s1")
        )
        queue.enqueue(event)
        XCTAssertEqual(queue.count, 1)

        consent.optOut()
        XCTAssertEqual(queue.count, 0)
    }
}

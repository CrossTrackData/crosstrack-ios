import Foundation

final class CrossTrackApiImpl: CrossTrackApi {
    private let eventQueue: EventQueue
    private let apiClient: ApiClient
    private let visitorIdManager: VisitorIdManager
    private let sessionManager: SessionManager
    private let consentProvider: () -> ConsentState
    private var userId: String?

    init(
        eventQueue: EventQueue,
        apiClient: ApiClient,
        visitorIdManager: VisitorIdManager,
        sessionManager: SessionManager,
        consentProvider: @escaping () -> ConsentState
    ) {
        self.eventQueue = eventQueue
        self.apiClient = apiClient
        self.visitorIdManager = visitorIdManager
        self.sessionManager = sessionManager
        self.consentProvider = consentProvider
    }

    func track(_ eventType: String, properties: [String: Any]) {
        guard consentProvider() == .optedIn else { return }
        let event = buildEvent(type: eventType, properties: properties)
        eventQueue.enqueue(event)
    }

    func screen(_ screenName: String, properties: [String: Any]) {
        var props = properties
        props["screen"] = screenName
        track("screen_view", properties: props)
    }

    func identify(_ userId: String, traits: [String: Any]) {
        self.userId = userId
        guard consentProvider() == .optedIn else { return }
        apiClient.sendIdentify(
            anonymousId: visitorIdManager.getVisitorId(),
            userId: userId,
            traits: traits
        ) { success in
            if !success {
                Logger.warn("Identify call failed for userId: \(userId)")
            }
        }
    }

    func flush() {
        eventQueue.flush()
    }

    func reset() {
        userId = nil
        eventQueue.clear()
        visitorIdManager.reset()
        sessionManager.reset()
    }

    private func buildEvent(type: String, properties: [String: Any]) -> Event {
        Event(
            anonymousId: visitorIdManager.getVisitorId(),
            userId: userId,
            type: type,
            properties: properties,
            context: EventContext(sessionId: sessionManager.getSessionId())
        )
    }
}

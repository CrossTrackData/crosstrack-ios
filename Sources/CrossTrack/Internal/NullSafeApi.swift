import Foundation

final class NullSafeCrossTrackApi: CrossTrackApi {
    func track(_ eventType: String, properties: [String: Any]) {}
    func screen(_ screenName: String, properties: [String: Any]) {}
    func identify(_ userId: String, traits: [String: Any]) {}
    func flush() {}
    func reset() {}
}

final class NullSafeConsentApi: ConsentApi {
    func optIn() {}
    func optOut() {}
    func getConsent() -> ConsentState { .notSet }
    func setConsent(_ state: ConsentState) {}
}

final class NullSafeSessionApi: SessionApi {
    func getSessionId() -> String { "" }
    func getVisitorId() -> String { "" }
    func getSessionInfo() -> String { "{}" }
    func decorateLink(_ url: String) -> String { url }
}

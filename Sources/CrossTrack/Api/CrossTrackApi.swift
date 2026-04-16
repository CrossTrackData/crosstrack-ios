import Foundation

public protocol CrossTrackApi {
    func track(_ eventType: String, properties: [String: Any])
    func screen(_ screenName: String, properties: [String: Any])
    func identify(_ userId: String, traits: [String: Any])
    func flush()
    func reset()
}

public extension CrossTrackApi {
    func track(_ eventType: String) {
        track(eventType, properties: [:])
    }

    func screen(_ screenName: String) {
        screen(screenName, properties: [:])
    }

    func identify(_ userId: String) {
        identify(userId, traits: [:])
    }
}

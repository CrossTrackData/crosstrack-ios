import Foundation

final class SessionApiImpl: SessionApi {
    private let visitorIdManager: VisitorIdManager
    private let sessionManager: SessionManager

    init(visitorIdManager: VisitorIdManager, sessionManager: SessionManager) {
        self.visitorIdManager = visitorIdManager
        self.sessionManager = sessionManager
    }

    func getSessionId() -> String {
        sessionManager.getSessionId()
    }

    func getVisitorId() -> String {
        visitorIdManager.getVisitorId()
    }

    func getSessionInfo() -> String {
        let info: [String: String] = [
            "visitorId": getVisitorId(),
            "sessionId": getSessionId()
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: info),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    func decorateLink(_ url: String) -> String {
        guard var components = URLComponents(string: url) else { return url }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "ct_vid", value: getVisitorId()))
        items.append(URLQueryItem(name: "ct_sid", value: getSessionId()))
        components.queryItems = items
        return components.string ?? url
    }
}

import Foundation

public protocol SessionApi {
    func getSessionId() -> String
    func getVisitorId() -> String
    func getSessionInfo() -> String
    func decorateLink(_ url: String) -> String
}

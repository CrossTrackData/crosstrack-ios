import Foundation

final class SessionManager {
    private static let sessionIdKey = "crosstrack_session_id"
    private static let lastActivityKey = "crosstrack_session_last_activity"

    private let storage: Storage
    private let sessionTimeoutMs: Int
    private let lock = NSLock()

    init(storage: Storage, sessionTimeoutMs: Int = 30 * 60 * 1000) {
        self.storage = storage
        self.sessionTimeoutMs = sessionTimeoutMs
    }

    func getSessionId() -> String {
        lock.lock()
        defer { lock.unlock() }

        let now = Int(Date().timeIntervalSince1970 * 1000)
        let existingId = storage.getString(Self.sessionIdKey)
        let lastActivity = storage.getString(Self.lastActivityKey).flatMap(Int.init)

        if let id = existingId, let last = lastActivity, now - last < sessionTimeoutMs {
            storage.putString(Self.lastActivityKey, value: String(now))
            return id
        }

        let newId = UUID().uuidString.lowercased()
        storage.putString(Self.sessionIdKey, value: newId)
        storage.putString(Self.lastActivityKey, value: String(now))
        return newId
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }
        storage.remove(Self.sessionIdKey)
        storage.remove(Self.lastActivityKey)
    }
}

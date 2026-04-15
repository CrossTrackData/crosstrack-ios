import Foundation

final class VisitorIdManager {
    private static let storageKey = "crosstrack_visitor_id"
    private let storage: Storage
    private let lock = NSLock()

    init(storage: Storage) {
        self.storage = storage
    }

    func getVisitorId() -> String {
        lock.lock()
        defer { lock.unlock() }
        if let existing = storage.getString(Self.storageKey) {
            return existing
        }
        let newId = UUID().uuidString.lowercased()
        storage.putString(Self.storageKey, value: newId)
        return newId
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }
        storage.remove(Self.storageKey)
    }
}

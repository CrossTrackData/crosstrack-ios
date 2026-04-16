@testable import CrossTrack

final class FakeStorage: Storage {
    private var data: [String: String] = [:]

    func getString(_ key: String) -> String? {
        data[key]
    }

    func putString(_ key: String, value: String) {
        data[key] = value
    }

    func remove(_ key: String) {
        data.removeValue(forKey: key)
    }

    func clear() {
        data.removeAll()
    }
}

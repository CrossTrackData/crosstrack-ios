import Foundation

final class UserDefaultsStorage: Storage {
    private let defaults: UserDefaults

    init() {
        self.defaults = UserDefaults(suiteName: "com.crosstrack.sdk") ?? .standard
    }

    func getString(_ key: String) -> String? {
        defaults.string(forKey: key)
    }

    func putString(_ key: String, value: String) {
        defaults.set(value, forKey: key)
    }

    func remove(_ key: String) {
        defaults.removeObject(forKey: key)
    }

    func clear() {
        guard let suiteName = defaults.volatileDomainNames.first else { return }
        defaults.removePersistentDomain(forName: suiteName)
    }
}

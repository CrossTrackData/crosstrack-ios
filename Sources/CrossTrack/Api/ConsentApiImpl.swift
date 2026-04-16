import Foundation

final class ConsentApiImpl: ConsentApi {
    private static let storageKey = "crosstrack_consent_state"
    private let storage: Storage
    private let lock = NSLock()
    private weak var eventQueue: EventQueue?
    private weak var visitorIdManager: VisitorIdManager?

    init(storage: Storage, eventQueue: EventQueue, visitorIdManager: VisitorIdManager) {
        self.storage = storage
        self.eventQueue = eventQueue
        self.visitorIdManager = visitorIdManager
    }

    func optIn() {
        setConsent(.optedIn)
    }

    func optOut() {
        setConsent(.optedOut)
    }

    func getConsent() -> ConsentState {
        lock.lock()
        defer { lock.unlock() }
        guard let raw = storage.getString(Self.storageKey),
              let state = ConsentState(rawValue: raw) else {
            return .notSet
        }
        return state
    }

    func setConsent(_ state: ConsentState) {
        lock.lock()
        storage.putString(Self.storageKey, value: state.rawValue)
        lock.unlock()

        if state == .optedOut {
            eventQueue?.clear()
            visitorIdManager?.reset()
            eventQueue?.stopTimer()
            Logger.info("Consent opted out: cleared queue and visitor ID")
        } else if state == .optedIn {
            eventQueue?.startTimer()
            Logger.info("Consent opted in: started flush timer")
        }
    }
}

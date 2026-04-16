import Foundation

struct RetryPolicy {
    let maxRetries: Int
    let baseDelayMs: Int
    let maxDelayMs: Int

    init(maxRetries: Int = 3, baseDelayMs: Int = 1000, maxDelayMs: Int = 60000) {
        self.maxRetries = maxRetries
        self.baseDelayMs = baseDelayMs
        self.maxDelayMs = maxDelayMs
    }

    func delay(for attempt: Int) -> TimeInterval {
        let delayMs = min(baseDelayMs * (1 << attempt), maxDelayMs)
        return TimeInterval(delayMs) / 1000.0
    }
}

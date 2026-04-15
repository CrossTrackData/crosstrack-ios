import Foundation

final class EventQueue {
    private var queue: [Event] = []
    private let lock = NSLock()
    private let maxQueueSize: Int
    private let flushIntervalMs: Int
    private var timer: DispatchSourceTimer?
    private let apiClient: ApiClient
    private let timerQueue = DispatchQueue(label: "com.crosstrack.sdk.timer")

    init(apiClient: ApiClient, maxQueueSize: Int = 500, flushIntervalMs: Int = 30000) {
        self.apiClient = apiClient
        self.maxQueueSize = maxQueueSize
        self.flushIntervalMs = flushIntervalMs
    }

    func enqueue(_ event: Event) {
        lock.lock()
        if queue.count >= maxQueueSize {
            queue.removeFirst()
            Logger.warn("Event queue full, dropped oldest event")
        }
        queue.append(event)
        lock.unlock()
    }

    func flush(completion: (() -> Void)? = nil) {
        lock.lock()
        guard !queue.isEmpty else {
            lock.unlock()
            completion?()
            return
        }
        let events = queue
        queue.removeAll()
        lock.unlock()

        apiClient.sendEvents(events) { [weak self] success in
            if !success {
                Logger.warn("Flush failed, re-enqueuing \(events.count) events")
                self?.lock.lock()
                self?.queue.insert(contentsOf: events, at: 0)
                self?.lock.unlock()
            }
            completion?()
        }
    }

    func startTimer() {
        stopTimer()
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        let interval = DispatchTimeInterval.milliseconds(flushIntervalMs)
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.flush()
        }
        timer.resume()
        self.timer = timer
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func clear() {
        lock.lock()
        queue.removeAll()
        lock.unlock()
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return queue.count
    }
}

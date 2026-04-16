import Foundation

public struct CrossTrackConfig {
    public let apiKey: String
    public let collectionUrl: String
    public let flushIntervalMs: Int
    public let maxQueueSize: Int
    public let maxBatchSizeBytes: Int
    public let sessionTimeoutMs: Int
    public let logLevel: LogLevel
    public let webViewDomains: [String]

    public init(
        apiKey: String,
        collectionUrl: String = "https://crosstrack.onrender.com",
        flushIntervalMs: Int = 30000,
        maxQueueSize: Int = 500,
        maxBatchSizeBytes: Int = 102400,
        sessionTimeoutMs: Int = 30 * 60 * 1000,
        logLevel: LogLevel = .warn,
        webViewDomains: [String] = []
    ) {
        self.apiKey = apiKey
        self.collectionUrl = collectionUrl
        self.flushIntervalMs = flushIntervalMs
        self.maxQueueSize = maxQueueSize
        self.maxBatchSizeBytes = maxBatchSizeBytes
        self.sessionTimeoutMs = sessionTimeoutMs
        self.logLevel = logLevel
        self.webViewDomains = webViewDomains
    }
}

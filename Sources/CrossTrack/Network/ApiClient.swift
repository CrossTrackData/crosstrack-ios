import Foundation

final class ApiClient {
    private let baseUrl: String
    private let apiKey: String
    private let session: URLSession
    private let retryPolicy: RetryPolicy
    private let encoder: JSONEncoder

    init(baseUrl: String, apiKey: String, retryPolicy: RetryPolicy = RetryPolicy()) {
        self.baseUrl = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
        self.apiKey = apiKey
        self.retryPolicy = retryPolicy
        self.encoder = JSONEncoder()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func sendEvents(_ events: [Event], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/v1/events/batch") else {
            Logger.error("Invalid URL: \(baseUrl)/v1/events/batch")
            completion(false)
            return
        }

        let body: [String: Any] = ["events": events.map { eventToDict($0) }]
        sendRequest(url: url, body: body, attempt: 0, completion: completion)
    }

    func sendIdentify(anonymousId: String, userId: String, traits: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/v1/identify") else {
            Logger.error("Invalid URL: \(baseUrl)/v1/identify")
            completion(false)
            return
        }

        var body: [String: Any] = [
            "anonymousId": anonymousId,
            "userId": userId
        ]
        if !traits.isEmpty {
            body["traits"] = traits
        }
        sendRequest(url: url, body: body, attempt: 0, completion: completion)
    }

    private func sendRequest(url: URL, body: [String: Any], attempt: Int, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            Logger.error("Failed to serialize request body: \(error)")
            completion(false)
            return
        }

        session.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }

            if let error = error {
                Logger.warn("Request failed: \(error.localizedDescription)")
                self.retryIfNeeded(url: url, body: body, attempt: attempt, completion: completion)
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                Logger.debug("Request succeeded: \(url.path)")
                completion(true)
            } else {
                Logger.warn("Request failed with status \(statusCode): \(url.path)")
                self.retryIfNeeded(url: url, body: body, attempt: attempt, completion: completion)
            }
        }.resume()
    }

    private func retryIfNeeded(url: URL, body: [String: Any], attempt: Int, completion: @escaping (Bool) -> Void) {
        guard attempt < retryPolicy.maxRetries else {
            Logger.error("Max retries exceeded for \(url.path)")
            completion(false)
            return
        }

        let delay = retryPolicy.delay(for: attempt)
        Logger.debug("Retrying \(url.path) in \(delay)s (attempt \(attempt + 1))")

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.sendRequest(url: url, body: body, attempt: attempt + 1, completion: completion)
        }
    }

    private func eventToDict(_ event: Event) -> [String: Any] {
        var dict: [String: Any] = [
            "eventId": event.eventId,
            "anonymousId": event.anonymousId,
            "type": event.type,
            "timestamp": event.timestamp,
            "context": contextToDict(event.context)
        ]
        if let userId = event.userId {
            dict["userId"] = userId
        }
        if !event.properties.isEmpty {
            dict["properties"] = event.properties.mapValues { unwrap($0.value) }
        }
        return dict
    }

    private func contextToDict(_ context: EventContext) -> [String: Any] {
        var dict: [String: Any] = [
            "sdkVersion": context.sdkVersion,
            "platform": context.platform,
            "sessionId": context.sessionId
        ]
        if let bridgeId = context.bridgeId {
            dict["bridgeId"] = bridgeId
        }
        return dict
    }

    private func unwrap(_ value: Any) -> Any {
        if let codable = value as? AnyCodable {
            return unwrap(codable.value)
        }
        if let dict = value as? [String: Any] {
            return dict.mapValues { unwrap($0) }
        }
        if let array = value as? [Any] {
            return array.map { unwrap($0) }
        }
        return value
    }
}

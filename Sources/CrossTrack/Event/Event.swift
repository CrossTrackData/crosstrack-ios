import Foundation

struct Event: Codable {
    let eventId: String
    let anonymousId: String
    let userId: String?
    let type: String
    let properties: [String: AnyCodable]
    let context: EventContext
    let timestamp: String

    init(
        eventId: String = UUID().uuidString.lowercased(),
        anonymousId: String,
        userId: String? = nil,
        type: String,
        properties: [String: Any] = [:],
        context: EventContext,
        timestamp: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.eventId = eventId
        self.anonymousId = anonymousId
        self.userId = userId
        self.type = type
        self.properties = properties.mapValues { AnyCodable($0) }
        self.context = context
        self.timestamp = timestamp
    }
}

struct EventContext: Codable {
    let bridgeId: String?
    let sdkVersion: String
    let platform: String
    let sessionId: String

    init(bridgeId: String? = nil, sdkVersion: String = "0.1.0", platform: String = "ios", sessionId: String) {
        self.bridgeId = bridgeId
        self.sdkVersion = sdkVersion
        self.platform = platform
        self.sessionId = sessionId
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String: try container.encode(string)
        case let int as Int: try container.encode(int)
        case let double as Double: try container.encode(double)
        case let bool as Bool: try container.encode(bool)
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

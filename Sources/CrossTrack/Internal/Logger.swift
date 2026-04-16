import Foundation
import os.log

public enum LogLevel: Int, Comparable {
    case verbose = 0, debug, info, warn, error, none

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

final class Logger {
    static var level: LogLevel = .warn
    private static let osLog = OSLog(subsystem: "com.crosstrack.sdk", category: "CrossTrack")

    static func verbose(_ message: @autoclosure () -> String) {
        log(.verbose, message())
    }

    static func debug(_ message: @autoclosure () -> String) {
        log(.debug, message())
    }

    static func info(_ message: @autoclosure () -> String) {
        log(.info, message())
    }

    static func warn(_ message: @autoclosure () -> String) {
        log(.warn, message())
    }

    static func error(_ message: @autoclosure () -> String) {
        log(.error, message())
    }

    private static func log(_ msgLevel: LogLevel, _ message: String) {
        guard msgLevel >= level else { return }
        let type: OSLogType
        switch msgLevel {
        case .verbose, .debug: type = .debug
        case .info: type = .info
        case .warn: type = .default
        case .error: type = .error
        case .none: return
        }
        os_log("%{public}@", log: osLog, type: type, message)
    }
}

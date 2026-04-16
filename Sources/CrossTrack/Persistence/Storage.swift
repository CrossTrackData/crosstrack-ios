import Foundation

protocol Storage {
    func getString(_ key: String) -> String?
    func putString(_ key: String, value: String)
    func remove(_ key: String)
    func clear()
}

import Foundation

public protocol ConsentApi {
    func optIn()
    func optOut()
    func getConsent() -> ConsentState
    func setConsent(_ state: ConsentState)
}

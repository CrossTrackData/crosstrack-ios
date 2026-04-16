import Foundation
#if canImport(WebKit)
import WebKit

public final class CrossTrackWKWebViewHandler: NSObject, WKNavigationDelegate {
    private static let bridgeKey = "crosstrack_device_id"
    private let visitorIdProvider: () -> String
    private let consentProvider: () -> ConsentState
    private let allowedDomains: [String]
    private weak var existingDelegate: WKNavigationDelegate?

    init(
        visitorIdProvider: @escaping () -> String,
        consentProvider: @escaping () -> ConsentState,
        allowedDomains: [String] = []
    ) {
        self.visitorIdProvider = visitorIdProvider
        self.consentProvider = consentProvider
        self.allowedDomains = allowedDomains
        super.init()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        existingDelegate?.webView?(webView, didFinish: navigation)

        guard consentProvider() == .optedIn else { return }

        if !allowedDomains.isEmpty {
            guard let host = webView.url?.host,
                  allowedDomains.contains(where: { host.hasSuffix($0) }) else {
                Logger.debug("WebView bridge skipped: domain not in allowlist")
                return
            }
        }

        let visitorId = visitorIdProvider()
        let js = "try { localStorage.setItem('\(Self.bridgeKey)', '\(visitorId)'); } catch(e) {}"
        webView.evaluateJavaScript(js) { _, error in
            if let error = error {
                Logger.warn("WebView bridge injection failed: \(error.localizedDescription)")
            } else {
                Logger.debug("WebView bridge injected visitor ID: \(visitorId)")
            }
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        existingDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        existingDelegate?.webView?(webView, didFail: navigation, withError: error)
    }

    func chainDelegate(_ delegate: WKNavigationDelegate?) {
        existingDelegate = delegate
    }
}
#endif

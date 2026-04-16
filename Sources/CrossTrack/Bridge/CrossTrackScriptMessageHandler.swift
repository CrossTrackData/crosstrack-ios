import Foundation
#if canImport(WebKit)
import WebKit

public final class CrossTrackScriptMessageHandler: NSObject, WKScriptMessageHandler {
    static let messageName = "CrossTrackBridge"

    private let sessionInfoProvider: () -> String
    private let visitorIdProvider: () -> String
    private let consentProvider: () -> ConsentState

    init(
        sessionInfoProvider: @escaping () -> String,
        visitorIdProvider: @escaping () -> String,
        consentProvider: @escaping () -> ConsentState
    ) {
        self.sessionInfoProvider = sessionInfoProvider
        self.visitorIdProvider = visitorIdProvider
        self.consentProvider = consentProvider
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? String else {
            Logger.warn("Bridge received non-string message")
            return
        }

        let response: String
        switch body {
        case "getSessionInfo":
            response = sessionInfoProvider()
        case "getVisitorId":
            response = "\"\(visitorIdProvider())\""
        case "getConsentState":
            response = "\"\(consentProvider().rawValue)\""
        default:
            Logger.warn("Bridge received unknown action: \(body)")
            return
        }

        let js = "window.__crosstrack_response = \(response);"
        message.webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    func installBridgeScript(on webView: WKWebView) {
        let script = WKUserScript(
            source: """
            window.CrossTrackBridge = {
                getVisitorId: function() {
                    window.webkit.messageHandlers.\(Self.messageName).postMessage('getVisitorId');
                    return window.__crosstrack_response;
                },
                getSessionInfo: function() {
                    window.webkit.messageHandlers.\(Self.messageName).postMessage('getSessionInfo');
                    return window.__crosstrack_response;
                },
                getConsentState: function() {
                    window.webkit.messageHandlers.\(Self.messageName).postMessage('getConsentState');
                    return window.__crosstrack_response;
                }
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: Self.messageName)
    }
}
#endif

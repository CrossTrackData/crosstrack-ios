import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(WebKit)
import WebKit
#endif

public final class CrossTrack {
    public static let shared = CrossTrack()

    private let lock = NSLock()
    private var isInitialized = false

    private var _api: CrossTrackApi = NullSafeCrossTrackApi()
    private var _consentApi: ConsentApi = NullSafeConsentApi()
    private var _sessionApi: SessionApi = NullSafeSessionApi()
    #if canImport(WebKit)
    private var _webViewHandler: CrossTrackWKWebViewHandler?
    private var _scriptMessageHandler: CrossTrackScriptMessageHandler?
    #endif
    private var eventQueue: EventQueue?
    private var lifecycleObservers: [NSObjectProtocol] = []

    private init() {}

    // MARK: - Initialization

    public func initialize(config: CrossTrackConfig) {
        lock.lock()
        defer { lock.unlock() }

        guard !isInitialized else {
            Logger.warn("CrossTrack already initialized")
            return
        }

        Logger.level = config.logLevel

        let storage = UserDefaultsStorage()
        let visitorIdManager = VisitorIdManager(storage: storage)
        let sessionManager = SessionManager(storage: storage, sessionTimeoutMs: config.sessionTimeoutMs)
        let apiClient = ApiClient(baseUrl: config.collectionUrl, apiKey: config.apiKey)
        let queue = EventQueue(apiClient: apiClient, maxQueueSize: config.maxQueueSize, flushIntervalMs: config.flushIntervalMs)

        let consentApi = ConsentApiImpl(storage: storage, eventQueue: queue, visitorIdManager: visitorIdManager)

        let api = CrossTrackApiImpl(
            eventQueue: queue,
            apiClient: apiClient,
            visitorIdManager: visitorIdManager,
            sessionManager: sessionManager,
            consentProvider: { consentApi.getConsent() }
        )

        let sessionApi = SessionApiImpl(visitorIdManager: visitorIdManager, sessionManager: sessionManager)

        self._api = api
        self._consentApi = consentApi
        self._sessionApi = sessionApi
        self.eventQueue = queue

        #if canImport(WebKit)
        self._webViewHandler = CrossTrackWKWebViewHandler(
            visitorIdProvider: { visitorIdManager.getVisitorId() },
            consentProvider: { consentApi.getConsent() },
            allowedDomains: config.webViewDomains
        )

        self._scriptMessageHandler = CrossTrackScriptMessageHandler(
            sessionInfoProvider: { sessionApi.getSessionInfo() },
            visitorIdProvider: { visitorIdManager.getVisitorId() },
            consentProvider: { consentApi.getConsent() }
        )
        #endif

        if consentApi.getConsent() == .optedIn {
            queue.startTimer()
        }

        registerLifecycleObservers()
        isInitialized = true

        Logger.info("CrossTrack initialized with visitor ID: \(visitorIdManager.getVisitorId())")
    }

    public func shutdown() {
        lock.lock()
        defer { lock.unlock() }

        guard isInitialized else { return }

        eventQueue?.flush()
        eventQueue?.stopTimer()
        removeLifecycleObservers()

        _api = NullSafeCrossTrackApi()
        _consentApi = NullSafeConsentApi()
        _sessionApi = NullSafeSessionApi()
        #if canImport(WebKit)
        _webViewHandler = nil
        _scriptMessageHandler = nil
        #endif
        eventQueue = nil
        isInitialized = false

        Logger.info("CrossTrack shut down")
    }

    // MARK: - Public API Accessors

    public func api() -> CrossTrackApi { _api }
    public func consent() -> ConsentApi { _consentApi }
    public func session() -> SessionApi { _sessionApi }

    // MARK: - Convenience Methods

    public func track(_ eventType: String, properties: [String: Any] = [:]) {
        _api.track(eventType, properties: properties)
    }

    public func screen(_ screenName: String, properties: [String: Any] = [:]) {
        _api.screen(screenName, properties: properties)
    }

    public func identify(_ userId: String, traits: [String: Any] = [:]) {
        _api.identify(userId, traits: traits)
    }

    public func flush() {
        _api.flush()
    }

    public func reset() {
        _api.reset()
    }

    // MARK: - WebView Bridge

    #if canImport(WebKit)
    public func webViewHandler() -> WKNavigationDelegate? {
        _webViewHandler
    }

    public func installBridge(on webView: WKWebView) {
        _scriptMessageHandler?.installBridgeScript(on: webView)
        webView.navigationDelegate = _webViewHandler
    }
    #endif

    // MARK: - Lifecycle

    private func registerLifecycleObservers() {
        #if canImport(UIKit)
        let center = NotificationCenter.default

        lifecycleObservers.append(
            center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
                Logger.debug("App entered background, flushing events")
                self?.eventQueue?.flush()
            }
        )

        lifecycleObservers.append(
            center.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
                Logger.debug("App terminating, flushing events")
                self?.eventQueue?.flush()
            }
        )

        lifecycleObservers.append(
            center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                _ = self?._sessionApi.getSessionId()
            }
        )
        #endif
    }

    private func removeLifecycleObservers() {
        lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
        lifecycleObservers.removeAll()
    }
}

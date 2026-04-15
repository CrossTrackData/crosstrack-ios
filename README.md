# CrossTrack iOS SDK

[![v0.1.0](https://img.shields.io/badge/version-0.1.0-blue)](https://github.com/CrossTrackData/crosstrack-ios) [![License](https://img.shields.io/badge/license-proprietary-lightgrey)](https://crosstrack-site.onrender.com)

Native Swift SDK for cross-platform identity resolution on iOS. Tracks visitor IDs, manages sessions, and bridges identity between your app and WKWebViews.

Zero third-party dependencies. iOS 14+.

## Installation

### Swift Package Manager

In Xcode: File → Add Package Dependencies → paste:

```
https://github.com/CrossTrackData/crosstrack-ios
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CrossTrackData/crosstrack-ios", from: "0.1.0")
]
```

## Quick Start

```swift
// In AppDelegate or app entry point
CrossTrack.shared.initialize(
    config: CrossTrackConfig(
        apiKey: "YOUR_API_KEY",
        collectionUrl: "https://crosstrack.onrender.com"
    )
)
CrossTrack.shared.consent().optIn()

// Track events
CrossTrack.shared.track("screen_view", properties: ["screen": "home"])

// When user logs in
CrossTrack.shared.identify("user_123", traits: ["email_hash": "sha256..."])

// WebView bridge — one line
CrossTrack.shared.installBridge(on: myWebView)
```

## Features

- Persistent visitor ID (UserDefaults)
- Session management (30-min timeout)
- Three-state consent (opted_in, opted_out, not_set)
- Event queue with batched flush and retry
- WKWebView bridge (app to web, automatic)
- JavaScript bridge (web to app via WKScriptMessageHandler)
- Null-safe proxy pattern (safe to call before init)
- App lifecycle hooks (flush on background/terminate)

## Get Your API Key

Sign up free at [crosstrack-dashboard.onrender.com](https://crosstrack-dashboard.onrender.com)

## Links

- [Landing Page](https://crosstrack-site.onrender.com)
- [Live Demo](https://crosstrack-demo.onrender.com)

# v0.1.0

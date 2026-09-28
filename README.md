# TouchVisualization

Display touch indicators throughout an iOS app, with one application-wide switch. TouchVisualization supports SwiftUI and UIKit, uses Swift 6 language mode, and has no external dependencies.

Requires **iOS 17+** and **Swift 6.3+**.

## Usage

Add [TouchVisualization](https://github.com/lynnswap/TouchVisualization) as a Swift package dependency and link its library product to your app target. Enable or disable touch indicators from the main actor:

```swift
import TouchVisualization

@MainActor
func setTouchVisualizationEnabled(_ enabled: Bool) {
    TouchVisualizer.shared.isEnabled = enabled
}
```

Visualization starts disabled. Your app controls when to enable it and whether to persist the setting. See the [API documentation](https://lynnswap.github.io/TouchVisualization/documentation/touchvisualization/) for the API contract and integration details.

## License

MIT. Copyright (c) 2026 Kazuki Nakashima. See [LICENSE](LICENSE).

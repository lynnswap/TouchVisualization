# TouchVisualization

Display touch indicators throughout an iOS app, with one application-wide switch. TouchVisualization supports SwiftUI and UIKit, uses Swift 6 language mode, and has no external dependencies.

Requires **iOS 17+** and **Swift 6.3+**.

## Usage

Add [TouchVisualization](https://github.com/lynnswap/TouchVisualization) as a Swift package dependency and link its library product to your app target. Enable or disable touch indicators from the main actor:

```swift
import TouchVisualization

TouchVisualizer.shared.isEnabled = true
```

Visualization starts disabled. Set `isEnabled` to `false` to remove all indicators. See the [API documentation](https://lynnswap.github.io/TouchVisualization/documentation/touchvisualization/) for appearance customization and behavior.

## License

MIT. Copyright (c) 2026 Kazuki Nakashima. See [LICENSE](LICENSE).

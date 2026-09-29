# TouchVisualization

Display touch indicators across UIKit and SwiftUI screens for demos, presentations, and screen recordings. Enable visualization throughout an iOS app with one switch, and customize the indicators' colors and size.

## Requirements

- iOS 17+
- Xcode on macOS with Swift 6.3+

## Quick start

Add [TouchVisualization](https://github.com/lynnswap/TouchVisualization) as a Swift package dependency and link the `TouchVisualization` library to your app target. Access the shared visualizer on the main actor.

### Show touch indicators

```swift
import TouchVisualization

TouchVisualizer.shared.isEnabled = true
```

Indicators follow touches across all windows without intercepting input. No view, scene, or window registration is required. Visualization starts disabled; set `isEnabled` to `false` to remove all indicators immediately.

### Customize the appearance

```swift
TouchVisualizer.shared.configuration = .init(
    strokeColor: .systemOrange,
    fillColor: .systemYellow.withAlphaComponent(0.3),
    strokeWidth: 2,
    diameter: 48
)
```

Stroke and fill colors, including their opacity, are independent. Changes apply immediately to current and future indicators. Assign `TouchVisualizer.Configuration()` to restore the default appearance.

`TouchVisualizer` supports Observation, so SwiftUI views update when the settings they read change.

## Documentation

See [DocC](https://lynnswap.github.io/TouchVisualization/documentation/touchvisualization/) for the API reference and behavior details.

To try touch visualization with standard controls, navigation, and sheets, run the [demo app](Examples/TouchVisualizationDemo).

## Acknowledgements

TouchVisualization was built with [ShowTime](https://github.com/KaneCheshire/ShowTime) as a reference for displaying touch indicators across an app's windows. Thank you to [Kane Cheshire](https://github.com/KaneCheshire) and the [ShowTime contributors](https://github.com/KaneCheshire/ShowTime/graphs/contributors) for creating and sharing it.

## License

[MIT License](LICENSE). Copyright (c) 2026 Kazuki Nakashima.

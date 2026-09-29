# ``TouchVisualization``

Display touch indicators throughout an iOS app.

## Overview

Use ``TouchVisualizer/shared`` on the main actor to enable touch indicators across UIKit and SwiftUI screens. No view, scene, or window registration is required.

```swift
import TouchVisualization

TouchVisualizer.shared.isEnabled = true
```

Visualization starts disabled. Set `isEnabled` to `false` to remove all indicators immediately. Settings are not persisted, and the API is available in every build configuration.

Indicators follow individual touches without intercepting input or participating in accessibility. Apple Pencil input is excluded. Existing indicators clear when the application resigns active, while the enabled setting is retained.

``TouchVisualizer`` supports Observation. SwiftUI views that read `isEnabled` or `configuration` update when those values change.

### Customizing indicators

Set ``TouchVisualizer/configuration`` to change the outline color, fill color, outline width, or circle diameter. The two colors and their opacities are independent. By default, both use system blue, with the fill at 50% opacity.

```swift
TouchVisualizer.shared.configuration = .init(
    strokeColor: .systemOrange,
    fillColor: .systemYellow.withAlphaComponent(0.3),
    strokeWidth: 2,
    diameter: 48
)
```

Configuration changes apply immediately to visible indicators, including those fading out, and to future touches. Updating the configuration preserves each indicator's position and does not change whether visualization is enabled. You can also modify a single property, such as `TouchVisualizer.shared.configuration.strokeColor = .systemRed`.

Dynamic colors resolve using the displaying window's traits and update when its system color appearance changes. Reset the appearance by assigning `TouchVisualizer.Configuration()`. Configuration values are not persisted.

### Event handling

When first enabled, the package exchanges the implementation of `UIWindow.sendEvent(_:)` to observe touch events before dispatching them to the app. It always calls the original implementation. Disabling visualization leaves the hook installed to preserve other libraries' hook chains. Custom window subclasses must call `super.sendEvent(_:)` for their touches to appear.

Each touch event updates that window's indicators to match its current touches. If a touch's ending was missed, its indicator fades out when the next touch event reaches the same window. Stationary touches remain visible without a time limit.

## Topics

### Controlling visualization

- ``TouchVisualizer``

### Customizing appearance

- ``TouchVisualizer/Configuration``
- ``TouchVisualizer/configuration``

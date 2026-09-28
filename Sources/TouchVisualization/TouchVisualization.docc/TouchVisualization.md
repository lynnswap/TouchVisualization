# ``TouchVisualization``

Display touch indicators throughout an iOS app.

## Overview

Use ``TouchVisualizer/shared`` to control visualization across the application. The same setting applies to UIKit and SwiftUI screens, including apps that use both. No view, scene, or window registration is required.

```swift
import TouchVisualization

@MainActor
func setTouchVisualizationEnabled(_ enabled: Bool) {
    TouchVisualizer.shared.isEnabled = enabled
}
```

Visualization starts disabled. Turning it off removes all indicators immediately. The package does not persist settings; restore and update the shared visualizer from whatever settings mechanism your app uses. The API is available in every build configuration. Your app decides when to enable visualization.

Indicators follow individual touches without intercepting input or participating in accessibility. Apple Pencil input is excluded. Existing indicators clear when the application resigns active, while the enabled setting is retained.

### Customizing indicators

Set ``TouchVisualizer/configuration`` to change the indicator color, outline width, or circle diameter. The outline uses the specified color, and the fill uses the same color at half its opacity.

```swift
@MainActor
func configureTouchIndicators() {
    var configuration = TouchVisualizer.Configuration()
    configuration.color = .systemOrange
    configuration.strokeWidth = 2
    configuration.diameter = 48

    TouchVisualizer.shared.configuration = configuration
}
```

Configuration changes apply immediately to visible indicators, including those fading out, and to future touches. Updating the configuration preserves each indicator's position and does not change whether visualization is enabled. You can also modify a single property, such as `TouchVisualizer.shared.configuration.color = .systemRed`.

Dynamic colors resolve using the displaying window's traits and update when its system color appearance changes. Reset the appearance by assigning `TouchVisualizer.Configuration()`. Configuration values are not persisted.

### Event handling

When first enabled, the package exchanges the implementation of `UIWindow.sendEvent(_:)` to observe touch events. It always calls the original implementation. Disabling visualization leaves the hook installed to preserve other libraries' hook chains. Custom window subclasses must call `super.sendEvent(_:)` for their touches to appear.

## Topics

### Controlling visualization

- ``TouchVisualizer``

### Customizing appearance

- ``TouchVisualizer/Configuration``
- ``TouchVisualizer/configuration``

# TouchVisualizationDemo

Open `TouchVisualization.xcworkspace` at the repository root, select the **TouchVisualizationDemo** scheme, and run it on an iOS Simulator or a configured iOS device. The app links the local package so library edits are included in the next build.

Enable **Show touches** to display touch positions throughout the app. Try the tap counter, slider, text field, scrolling list, navigation, and sheet. The toggle uses `@AppStorage`; the app restores its value on launch and applies changes directly to `TouchVisualizer.shared.isEnabled`.

Use **Appearance** to change the indicator color, outline width, and diameter. The fill automatically uses the same color at half its opacity. Changes apply to the whole app immediately. **Reset appearance** restores the package defaults. Appearance settings last for the current launch.

The toggle is available in both Debug and Release configurations.

To run the package's Swift Testing tests, open `Package.swift` at the repository root, select the **TouchVisualization** scheme and an iOS Simulator, then choose **Product → Test**. Use the same scheme with the Debug configuration and **Product → Build Documentation** to build DocC.

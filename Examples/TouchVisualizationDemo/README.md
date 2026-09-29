# TouchVisualizationDemo

Open `TouchVisualization.xcworkspace` at the repository root, select the **TouchVisualizationDemo** scheme, and run it on an iOS Simulator or a configured iOS device. The app links the local package so library edits are included in the next build.

Enable **Show touches** to display touch positions throughout the app. Try the tap counter, slider, text field, scrolling list, navigation, and sheet. The enabled setting is saved between launches.

Use **Appearance** to change the indicator color, outline width, and diameter. The demo sets the fill to the selected outline color at half its opacity; the package supports independent outline and fill colors. Changes apply to the whole app immediately. **Reset appearance** restores the package defaults. Appearance settings last for the current launch.

The toggle is available in both Debug and Release configurations.

To run the package's Swift Testing tests, select the **TouchVisualizationTests** scheme and an iOS Simulator in the workspace, then choose **Product → Test**. Select **TouchVisualization** with the Debug configuration and **Product → Build Documentation** to build DocC.

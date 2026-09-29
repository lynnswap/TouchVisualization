// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import SwiftUI
import TouchVisualization

@main
struct TouchVisualizationDemoApp: App {
    @AppStorage("showsTouches") private var showsTouches = false
    @State private var visualizer = TouchVisualizer.shared

    init() {
        visualizer.isEnabled = showsTouches
    }

    var body: some Scene {
        WindowGroup {
            ContentView(visualizer: visualizer)
                .onChange(of: visualizer.isEnabled) {
                    showsTouches = visualizer.isEnabled
                }
        }
    }
}

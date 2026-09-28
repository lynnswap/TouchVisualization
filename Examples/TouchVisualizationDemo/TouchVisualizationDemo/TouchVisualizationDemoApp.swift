// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import SwiftUI
import TouchVisualization

@main
struct TouchVisualizationDemoApp: App {
    @AppStorage("showsTouches") private var showsTouches = false

    init() {
        TouchVisualizer.shared.isEnabled = showsTouches
    }

    var body: some Scene {
        WindowGroup {
            ContentView(showsTouches: $showsTouches)
        }
    }
}

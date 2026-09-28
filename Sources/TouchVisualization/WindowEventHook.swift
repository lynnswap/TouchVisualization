// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import ObjectiveC
import UIKit

@MainActor
enum WindowEventHook {
    static func install() {
        _ = installation
    }

    // Keep the hook installed after disabling so other libraries' hook chains
    // are not changed. The visualizer simply ignores events while disabled.
    private static let installation: Void = {
        guard
            let original = class_getInstanceMethod(UIWindow.self, #selector(UIWindow.sendEvent(_:))),
            let replacement = class_getInstanceMethod(
                UIWindow.self,
                #selector(UIWindow.touchVisualization_sendEvent(_:))
            )
        else {
            preconditionFailure("The touch event methods must be registered on UIWindow.")
        }
        method_exchangeImplementations(original, replacement)
    }()
}

extension UIWindow {
    @objc dynamic fileprivate func touchVisualization_sendEvent(_ event: UIEvent) {
        touchVisualization_sendEvent(event)
        TouchVisualizer.shared.receive(event, in: self)
    }
}

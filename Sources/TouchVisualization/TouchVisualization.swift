// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import UIKit

/// Controls touch indicators across every window in the application.
///
/// Configure the shared instance on the main actor. TouchVisualization does not
/// persist this setting or restrict it to a particular build configuration.
@MainActor
public final class TouchVisualizer {
    /// The application's touch visualizer.
    public static let shared = TouchVisualizer()

    /// Whether touches are visible throughout the application. Defaults to false.
    ///
    /// Disabling visualization immediately removes all indicators.
    public var isEnabled = false {
        didSet {
            if isEnabled {
                WindowEventHook.install()
            } else {
                removeIndicators()
            }
        }
    }

    /// The appearance applied to current and future touch indicators.
    ///
    /// Changing the configuration updates visible indicators immediately, without
    /// changing `isEnabled`. The visualizer does not persist the configuration.
    public var configuration = Configuration() {
        didSet {
            let iterator = overlays.objectEnumerator()
            while let overlay = iterator?.nextObject() as? TouchOverlayView {
                overlay.configuration = configuration
            }
        }
    }

    private let overlays = NSMapTable<UIWindow, TouchOverlayView>.weakToStrongObjects()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(removeIndicators),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    func receive(_ event: UIEvent, in window: UIWindow) {
        guard isEnabled, let touches = event.touches(for: window) else { return }

        for touch in touches where touch.type != .stylus {
            let identifier = ObjectIdentifier(touch)
            switch touch.phase {
            case .began, .moved, .stationary:
                let overlay = overlay(in: window)
                window.bringSubviewToFront(overlay)
                overlay.show(identifier, at: touch.location(in: window))
            case .ended, .cancelled:
                overlays.object(forKey: window)?.finish(identifier)
            default:
                break
            }
        }
    }

    private func overlay(in window: UIWindow) -> TouchOverlayView {
        if let overlay = overlays.object(forKey: window) {
            return overlay
        }

        let overlay = TouchOverlayView(frame: window.bounds, configuration: configuration)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlay)
        overlays.setObject(overlay, forKey: window)
        return overlay
    }

    @objc private func removeIndicators() {
        let iterator = overlays.objectEnumerator()
        while let overlay = iterator?.nextObject() as? TouchOverlayView {
            overlay.removeFromSuperview()
        }
        overlays.removeAllObjects()
    }
}

// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import Observation
import UIKit

/// Controls touch indicators across every window in the application.
///
/// Configure the shared instance on the main actor. Changes to its settings
/// are observable. Settings are not persisted.
@available(iOS 17, *)
@MainActor
public final class TouchVisualizer: Observable {
    /// The application's touch visualizer.
    public static let shared = TouchVisualizer()

    /// Whether touches are visible throughout the application. Defaults to false.
    ///
    /// Disabling visualization immediately removes all indicators.
    public var isEnabled: Bool {
        get {
            Self.registrar.access(self, keyPath: \.isEnabled)
            return enabled
        }
        set {
            Self.registrar.withMutation(of: self, keyPath: \.isEnabled) {
                enabled = newValue
                if newValue {
                    WindowEventHook.install()
                } else {
                    removeIndicators()
                }
            }
        }
    }

    /// The appearance applied to current and future touch indicators.
    ///
    /// Changing the configuration updates visible indicators immediately, without
    /// changing `isEnabled`. The visualizer does not persist the configuration.
    public var configuration: Configuration {
        get {
            Self.registrar.access(self, keyPath: \.configuration)
            return currentConfiguration
        }
        set {
            Self.registrar.withMutation(of: self, keyPath: \.configuration) {
                currentConfiguration = newValue
                let iterator = overlays.objectEnumerator()
                while let overlay = iterator?.nextObject() as? TouchOverlayView {
                    overlay.configuration = newValue
                }
            }
        }
    }

    // iOS 16 can realize this class while enumerating Objective-C classes.
    // Keep ObservationRegistrar out of its instance layout until the singleton is used.
    private static let registrar = ObservationRegistrar()
    private var enabled = false
    private var currentConfiguration = Configuration()
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
        guard isEnabled, event.type == .touches else { return }

        var activeTouches: Set<ObjectIdentifier> = []
        for touch in event.touches(for: window) ?? [] where touch.type != .stylus {
            let identifier = ObjectIdentifier(touch)
            switch touch.phase {
            case .began, .moved, .stationary:
                activeTouches.insert(identifier)
                let overlay = overlay(in: window)
                window.bringSubviewToFront(overlay)
                overlay.show(identifier, at: touch.location(in: window))
            default:
                break
            }
        }

        // Reconcile the full window touch set so a missed ending cannot leave a stale indicator.
        overlays.object(forKey: window)?.finishTouches(except: activeTouches)
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

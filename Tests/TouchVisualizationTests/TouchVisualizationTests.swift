// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import Observation
import SwiftUI
import Testing
import UIKit
@testable import TouchVisualization

@Suite(.serialized)
@MainActor
struct TouchVisualizationTests {
    @Test
    func visualizerSettingsAreObservable() async {
        @Bindable var visualizer = TouchVisualizer.shared
        let originalIsEnabled = visualizer.isEnabled
        let originalConfiguration = visualizer.configuration
        defer {
            visualizer.isEnabled = originalIsEnabled
            visualizer.configuration = originalConfiguration
        }

        await confirmation("Changes to isEnabled are observed") { changed in
            withObservationTracking {
                _ = visualizer.isEnabled
            } onChange: {
                changed()
            }
            $visualizer.isEnabled.wrappedValue.toggle()
        }
        #expect(visualizer.isEnabled == !originalIsEnabled)

        await confirmation("Replacing the configuration is observed") { changed in
            withObservationTracking {
                _ = visualizer.configuration
            } onChange: {
                changed()
            }
            visualizer.configuration = .init(strokeColor: .red, fillColor: .green)
        }

        await confirmation("Editing a nested property through a binding is observed") { changed in
            withObservationTracking {
                _ = visualizer.configuration.diameter
            } onChange: {
                changed()
            }
            $visualizer.configuration.diameter.wrappedValue = 64
        }
        #expect(visualizer.configuration.diameter == 64)
        #expect(visualizer.configuration.strokeColor == .red)
        #expect(visualizer.configuration.fillColor == .green)
    }

    @Test
    func movingATouchReusesItsIndicator() throws {
        let overlay = TouchOverlayView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let touch = ObjectIdentifier(NSObject.self)

        overlay.show(touch, at: CGPoint(x: 40, y: 60))
        let indicator = try #require(overlay.subviews.first)

        overlay.show(touch, at: CGPoint(x: 100, y: 120))

        #expect(overlay.subviews.count == 1)
        #expect(overlay.subviews.first === indicator)
        #expect(indicator.center == CGPoint(x: 100, y: 120))
    }

    @Test
    func simultaneousTouchesHaveIndependentPositions() throws {
        let overlay = TouchOverlayView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let firstTouch = ObjectIdentifier(NSObject.self)
        let secondTouch = ObjectIdentifier(NSString.self)

        overlay.show(firstTouch, at: CGPoint(x: 40, y: 60))
        overlay.show(secondTouch, at: CGPoint(x: 200, y: 240))
        overlay.show(firstTouch, at: CGPoint(x: 80, y: 100))

        #expect(overlay.subviews.count == 2)
        #expect(overlay.subviews[0].center == CGPoint(x: 80, y: 100))
        #expect(overlay.subviews[1].center == CGPoint(x: 200, y: 240))
    }

    @Test
    func configurationUpdatesCurrentAndFutureIndicators() throws {
        let overlay = TouchOverlayView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let position = CGPoint(x: 40, y: 60)
        overlay.show(ObjectIdentifier(NSObject.self), at: position)
        let firstIndicator = try #require(overlay.subviews.first)

        overlay.configuration = .init(
            strokeColor: .red.withAlphaComponent(0.4),
            fillColor: .green.withAlphaComponent(0.7),
            strokeWidth: 4,
            diameter: 64
        )
        overlay.show(ObjectIdentifier(NSString.self), at: CGPoint(x: 200, y: 240))

        #expect(overlay.subviews.count == 2)
        #expect(overlay.subviews.first === firstIndicator)
        #expect(firstIndicator.center == position)
        for indicator in overlay.subviews {
            #expect(indicator.bounds.size == CGSize(width: 64, height: 64))
            #expect(indicator.layer.cornerRadius == 32)
            #expect(indicator.layer.borderWidth == 4)
            #expect(indicator.layer.borderColor == UIColor.red.withAlphaComponent(0.4).cgColor)
            #expect(indicator.backgroundColor == UIColor.green.withAlphaComponent(0.7))
        }

        overlay.configuration.strokeColor = .blue
        #expect(overlay.subviews.allSatisfy { $0.layer.borderColor == UIColor.blue.cgColor })
        #expect(overlay.subviews.allSatisfy { $0.backgroundColor == UIColor.green.withAlphaComponent(0.7) })

        overlay.configuration.fillColor = .clear
        #expect(overlay.subviews.allSatisfy { $0.backgroundColor == .clear })
        #expect(overlay.subviews.allSatisfy { $0.layer.borderColor == UIColor.blue.cgColor })

        overlay.configuration.strokeWidth = 0
        #expect(overlay.subviews.allSatisfy { $0.layer.borderWidth == 0 })
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func dynamicColorsUseTheOverlayTraits(style: UIUserInterfaceStyle) throws {
        let strokeColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .black
        }
        let fillColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.red.withAlphaComponent(0.3)
                : UIColor.green.withAlphaComponent(0.7)
        }
        let overlay = TouchOverlayView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 480),
            configuration: .init(strokeColor: strokeColor, fillColor: fillColor)
        )
        overlay.traitOverrides.userInterfaceStyle = style
        overlay.updateTraitsIfNeeded()
        overlay.show(ObjectIdentifier(NSObject.self), at: CGPoint(x: 40, y: 60))

        let indicator = try #require(overlay.subviews.first)
        let expectedStrokeColor: UIColor = style == .dark ? .white : .black
        let expectedFillColor =
            style == .dark ? UIColor.red.withAlphaComponent(0.3) : UIColor.green.withAlphaComponent(0.7)
        #expect(indicator.layer.borderColor == expectedStrokeColor.cgColor)
        #expect(indicator.backgroundColor == expectedFillColor)
    }

    @Test(arguments: [UITouch.Phase.ended, .cancelled])
    func endingATouchFadesItsIndicator(phase: UITouch.Phase) throws {
        try withEnabledVisualizer { visualizer in
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            let touch = TestTouch()
            let event = TestEvent(touches: [window: [touch]])
            visualizer.receive(event, in: window)
            let overlay = try #require(window.subviews.first as? TouchOverlayView)
            let indicator = try #require(overlay.subviews.first)

            touch.testPhase = phase
            visualizer.receive(event, in: window)

            #expect(indicator.alpha == 0)
        }
    }

    @Test
    func nextEventRemovesMissingTouchesAndPreservesStationaryTouches() throws {
        try withEnabledVisualizer { visualizer in
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            let missingTouch = TestTouch()
            let heldTouch = TestTouch()
            heldTouch.position = CGPoint(x: 200, y: 240)
            let event = TestEvent(touches: [window: [missingTouch, heldTouch]])
            visualizer.receive(event, in: window)
            let overlay = try #require(window.subviews.first as? TouchOverlayView)
            let missingIndicator = try #require(overlay.subviews.first { $0.center == missingTouch.position })
            let heldIndicator = try #require(overlay.subviews.first { $0.center == heldTouch.position })

            // The next event no longer contains the first touch, without delivering its ending.
            heldTouch.testPhase = .stationary
            let newTouch = TestTouch()
            newTouch.position = CGPoint(x: 100, y: 180)
            event.windowTouches[window] = [heldTouch, newTouch]
            visualizer.receive(event, in: window)

            #expect(missingIndicator.alpha == 0)
            #expect(heldIndicator.alpha == 1)
            #expect(overlay.subviews.filter { $0.alpha == 1 }.count == 2)

            visualizer.receive(event, in: window)
            #expect(heldIndicator.alpha == 1)
            #expect(overlay.subviews.filter { $0.alpha == 1 }.count == 2)
        }
    }

    @Test
    func emptyTouchSetClearsOnlyItsWindowAndOtherEventTypesDoNotClearTouches() throws {
        try withEnabledVisualizer { visualizer in
            let firstWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            let secondWindow = UIWindow(frame: firstWindow.frame)
            let event = TestEvent(touches: [firstWindow: [TestTouch()], secondWindow: [TestTouch()]])
            visualizer.receive(event, in: firstWindow)
            visualizer.receive(event, in: secondWindow)
            let firstOverlay = try #require(firstWindow.subviews.first as? TouchOverlayView)
            let secondOverlay = try #require(secondWindow.subviews.first as? TouchOverlayView)
            let firstIndicator = try #require(firstOverlay.subviews.first)
            let secondIndicator = try #require(secondOverlay.subviews.first)

            event.windowTouches = [:]
            event.testType = .motion
            visualizer.receive(event, in: firstWindow)
            #expect(firstIndicator.alpha == 1)
            #expect(secondIndicator.alpha == 1)

            event.testType = .touches
            visualizer.receive(event, in: firstWindow)
            #expect(firstIndicator.alpha == 0)
            #expect(secondIndicator.alpha == 1)
        }
    }

    private func withEnabledVisualizer(_ body: (TouchVisualizer) throws -> Void) rethrows {
        let visualizer = TouchVisualizer.shared
        let wasEnabled = visualizer.isEnabled
        visualizer.isEnabled = true
        defer {
            visualizer.isEnabled = false
            visualizer.isEnabled = wasEnabled
        }
        try body(visualizer)
    }

    @Test
    func indicatorsDoNotInterceptTouches() {
        let overlay = TouchOverlayView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let position = CGPoint(x: 40, y: 60)
        overlay.show(ObjectIdentifier(NSObject.self), at: position)

        #expect(overlay.hitTest(position, with: nil) == nil)
        #expect(overlay.accessibilityElementsHidden)
    }
}

@MainActor
private final class TestTouch: UITouch {
    var testPhase: UITouch.Phase = .began
    var position = CGPoint(x: 40, y: 60)

    override var phase: UITouch.Phase { testPhase }
    override var type: UITouch.TouchType { .direct }

    override func location(in view: UIView?) -> CGPoint {
        position
    }
}

@MainActor
private final class TestEvent: UIEvent {
    var testType: UIEvent.EventType = .touches
    var windowTouches: [UIWindow: Set<UITouch>]

    init(touches: [UIWindow: Set<UITouch>]) {
        windowTouches = touches
        super.init()
    }

    override var type: UIEvent.EventType { testType }

    override func touches(for window: UIWindow) -> Set<UITouch>? {
        windowTouches[window]
    }
}

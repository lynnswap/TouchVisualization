// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import Testing
import UIKit
@testable import TouchVisualization

@MainActor
struct TouchVisualizationTests {
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
            color: .red.withAlphaComponent(0.4),
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
            #expect(indicator.backgroundColor == UIColor.red.withAlphaComponent(0.2))
        }

        overlay.configuration.strokeWidth = 0
        #expect(overlay.subviews.allSatisfy { $0.layer.borderWidth == 0 })
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func dynamicColorUsesTheOverlayTraits(style: UIUserInterfaceStyle) throws {
        let color = UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .black
        }
        let overlay = TouchOverlayView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 480),
            configuration: .init(color: color)
        )
        overlay.traitOverrides.userInterfaceStyle = style
        overlay.updateTraitsIfNeeded()
        overlay.show(ObjectIdentifier(NSObject.self), at: CGPoint(x: 40, y: 60))

        let indicator = try #require(overlay.subviews.first)
        let expectedColor: UIColor = style == .dark ? .white : .black
        #expect(indicator.layer.borderColor == expectedColor.cgColor)
        #expect(indicator.backgroundColor == expectedColor.withAlphaComponent(0.5))
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

// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import UIKit

final class TouchOverlayView: UIView {
    var configuration: TouchVisualizer.Configuration {
        didSet {
            updateIndicators()
        }
    }

    private var indicators: [ObjectIdentifier: UIView] = [:]

    init(frame: CGRect, configuration: TouchVisualizer.Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: frame)
        isUserInteractionEnabled = false
        accessibilityElementsHidden = true
        backgroundColor = .clear

        registerForTraitChanges(UITraitCollection.systemTraitsAffectingColorAppearance) {
            (view: TouchOverlayView, _: UITraitCollection) in
            view.updateIndicators()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable.")
    }

    func show(_ identifier: ObjectIdentifier, at position: CGPoint) {
        if let indicator = indicators[identifier] {
            indicator.center = position
            return
        }

        let indicator = UIView()
        indicator.isUserInteractionEnabled = false
        applyConfiguration(to: indicator)
        indicator.center = position
        addSubview(indicator)
        indicators[identifier] = indicator
    }

    func finish(_ identifier: ObjectIdentifier) {
        guard let indicator = indicators.removeValue(forKey: identifier) else { return }

        UIView.animate(
            withDuration: 0.2,
            delay: 0.1,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            indicator.alpha = 0
            indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            indicator.removeFromSuperview()
        }
    }

    private func updateIndicators() {
        // Fading indicators remain in the hierarchy after leaving the active-touch map.
        for indicator in subviews {
            applyConfiguration(to: indicator)
        }
    }

    private func applyConfiguration(to indicator: UIView) {
        indicator.bounds.size = CGSize(width: configuration.diameter, height: configuration.diameter)
        indicator.layer.cornerRadius = configuration.diameter / 2
        indicator.layer.borderWidth = configuration.strokeWidth
        let color = configuration.color.resolvedColor(with: traitCollection)
        indicator.layer.borderColor = color.cgColor
        indicator.backgroundColor = color.withAlphaComponent(color.cgColor.alpha * 0.5)
    }
}

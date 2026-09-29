// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import UIKit

extension TouchVisualizer {
    /// The appearance of touch indicators throughout the application.
    public struct Configuration: Equatable {
        /// The outline color. Defaults to system blue.
        ///
        /// Dynamic colors resolve using the displaying window's traits.
        public var strokeColor: UIColor

        /// The fill color. Defaults to system blue at 50% opacity.
        ///
        /// Independent of `strokeColor`, including its opacity. Dynamic colors
        /// resolve using the displaying window's traits.
        public var fillColor: UIColor

        /// The outline width in points. Defaults to 2.
        public var strokeWidth: CGFloat

        /// The circle's diameter in points. Defaults to 44.
        public var diameter: CGFloat

        /// Creates a configuration with the specified appearance.
        public init(
            strokeColor: UIColor = .systemBlue,
            fillColor: UIColor = .systemBlue.withAlphaComponent(0.5),
            strokeWidth: CGFloat = 2,
            diameter: CGFloat = 44
        ) {
            self.strokeColor = strokeColor
            self.fillColor = fillColor
            self.strokeWidth = strokeWidth
            self.diameter = diameter
        }
    }
}

// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import UIKit

extension TouchVisualizer {
    /// The appearance of touch indicators throughout the application.
    public struct Configuration: Equatable {
        /// The indicator color. Defaults to system blue.
        ///
        /// The outline uses this color, and the fill uses half its opacity.
        /// Dynamic colors resolve using the displaying window's traits.
        public var color: UIColor

        /// The outline width in points. Defaults to 2.
        public var strokeWidth: CGFloat

        /// The circle's diameter in points. Defaults to 44.
        public var diameter: CGFloat

        /// Creates a configuration with the specified appearance.
        public init(
            color: UIColor = .systemBlue,
            strokeWidth: CGFloat = 2,
            diameter: CGFloat = 44
        ) {
            self.color = color
            self.strokeWidth = strokeWidth
            self.diameter = diameter
        }
    }
}

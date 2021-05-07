//
//  UIView+Animations.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation
import UIKit

/*!
 The intended direction of the animation
 - in:  Animate in
 - out: Animate out
 */
internal enum AnimationDirection {
    case `in` // swiftlint:disable:this identifier_name
    case out
}

internal extension UIView {

    /// The key for the fade animation
    var fadeKey: String { return "FadeAnimation" }

    func buttonHilightedAnimation(_ direction: AnimationDirection, _ value: Float, duration: CFTimeInterval = 0.08) {
        layer.removeAnimation(forKey: fadeKey)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = layer.presentation()?.opacity
        layer.opacity = value
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: fadeKey)
    }
}

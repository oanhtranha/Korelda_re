//
//  Extentions.swift
//  Koleda
//
//  Created by Oanh tran on 11/20/19.
//  Copyright © 2019 koleda. All rights reserved.
//

// MARK: -

// MARK: - Gradient layer extensions
extension CAGradientLayer {
    
    func removeIfAdded() {
        if self.superlayer != nil {
            self.removeFromSuperlayer()
        }
    }
    
}

// MARK: - Shapelayer extenxions
extension CAShapeLayer {
    
    func setBorder(color: UIColor, borderWidth: CGFloat) {
        self.borderColor = color.cgColor
        self.borderWidth = borderWidth
    }
    
    func setShadow(color: UIColor, opacity: Float, offset: CGFloat, radius: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = CGSize(width: offset, height: offset)
        shadowRadius = radius
    }
    
    func removeIfAdded() {
        if self.superlayer != nil {
            self.removeFromSuperlayer()
        }
    }
    
}

// MARK: - View extension
extension UIView {
    
    func setShadow(color: UIColor, opacity: Float, offset: CGFloat, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: offset, height: offset)
        layer.shadowRadius = radius
    }
    
    func getGradientLayerOf(frame: CGRect, colors: [CGColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = CAGradientLayerType.axial
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        return gradientLayer
    }
    
    func removeIfAdded() {
        if self.superview != nil {
            self.removeFromSuperview()
        }
    }
    
}

// MARK: - Integer extension
extension Int {
    
    public func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
    
}

// MARK: - binary integer extension
extension BinaryInteger {
    public var toRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

// MARK: - Floating point extension
extension FloatingPoint {
    public var toRadians: Self { return self * .pi / 180 }
    public var toDegree: Self { return self * 180 / .pi }
}

//
//  UIView+Appearance.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

internal extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func roundLeftCorners(cornerRadius: CGFloat = 4) {
        round(roundingCorners: [.bottomLeft, .topLeft], by: cornerRadius)
    }
    
    func roundCorners(cornerRadius: CGFloat = 4) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func resetCorners() {
        layer.cornerRadius = 0
        layer.mask = nil
    }
    
    private func round(roundingCorners: UIRectCorner, by cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: roundingCorners,
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    func setShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.cornerRadius = 3
        layer.masksToBounds = false
        
        layoutIfNeeded()
    }
    
    func removeShadow() {
        self.layer.shadowOffset = CGSize(width: 0 , height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0.0
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
        
        layoutIfNeeded()
    }
    
    func setHighlightedShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.cornerRadius = 3
        layer.masksToBounds = false
        
        layoutIfNeeded()
    }
    
}

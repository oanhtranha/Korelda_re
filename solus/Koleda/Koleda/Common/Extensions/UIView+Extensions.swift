
//
//  UIView+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 8/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//


import UIKit
import Foundation


extension UIView {
    func addshadowAllSides(cornerRadius: CGFloat, shadowColor: UIColor, shadowRadius: CGFloat = 5.0, borderWidth: CGFloat = 0, borderColor: UIColor = .white) {
        self.layer.cornerRadius = cornerRadius
        // border
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        
        // shadow
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = shadowRadius
    }
    
    static var kld_nib: UINib {
        return UINib(nibName: "\(self)", bundle: nil)
    }
    
    func kld_loadContentFromNib() {
        guard let contentView = type(of: self).kld_nib.instantiate(withOwner: self, options: nil).last as? UIView else {
            return
        }
        
        contentView.frame = self.bounds
        self.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            ])
    }

    @IBInspectable var borderWidth : CGFloat {
        set {
            layer.borderWidth = newValue
        }
        
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        
        get {
            return layer.cornerRadius
        }
    }
    

}

//
//  UIView+Constraints.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 01/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

internal extension UIView {
    
    func addConstraintsToSizeToParent(spacing: CGFloat = 0) {
        guard let view = superview else { fatalError() }
        let top = topAnchor.constraint(equalTo: view.topAnchor)
        let bottom = bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let left = leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = rightAnchor.constraint(equalTo: view.rightAnchor)
        view.addConstraints([top,bottom,left,right])
        if spacing != 0 {
            top.constant = spacing
            left.constant = spacing
            right.constant = -spacing
            bottom.constant = -spacing
        }
    }
    
    /// anchor the view to its super view with the specified space from each direction
    ///
    /// - Parameters:
    ///   - top: the space from the top anchor of the superview, if nil a constarint will not be created
    ///   - leading: the space from the leading anchor of the superview, if nil a constarint will not be created
    ///   - trailing: the space from the trailing anchor of the superview, if nil a constarint will not be created
    ///   - bottom: the space from the bottom anchor of the superview, if nil a constarint will not be created
    /// - Returns: an array of the constraints that where created.
    @discardableResult func anchorToSuperview(top: CGFloat? = 0, leading: CGFloat? = 0, trailing: CGFloat? = 0, bottom: CGFloat? = 0) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else { return [] }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let top = top {
            let anchor = topAnchor.constraint(equalTo: superview.topAnchor, constant: top)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let leading = leading {
            let anchor = leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let trailing = trailing {
            let anchor = superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let bottom = bottom {
            let anchor = superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        return constraints
    }
    
    /// anchor the view to its super view with the specified space from each direction
    ///
    /// - Parameters:
    ///   - top: the space from the top anchor of the superview, if nil a constarint will not be created
    ///   - leading: the space from the leading anchor of the superview, if nil a constarint will not be created
    ///   - trailing: the space from the trailing anchor of the superview, if nil a constarint will not be created
    ///   - bottom: the space from the bottom anchor of the superview, if nil a constarint will not be created
    /// - Returns: an array of the constraints that where created.
    @available(iOS 11.0, *)
    @discardableResult func anchorToSuperviewSafeArea(top: CGFloat? = 0, leading: CGFloat? = 0, trailing: CGFloat? = 0, bottom: CGFloat? = 0) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else { return [] }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let top = top {
            let anchor = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: top)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let leading = leading {
            let anchor = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: leading)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let trailing = trailing {
            let anchor = superview.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let bottom = bottom {
            let anchor = superview.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        return constraints
    }
    
    /// anchor the view to its super view with the same space from every direction
    ///
    /// - Parameter padding: the space from all directions. default value is 0
    /// - Returns: an array of the constraints that where created.
    @discardableResult func anchorToSuperview(padding: CGFloat = 0) -> [NSLayoutConstraint] {
        return anchorToSuperview(top: padding, leading: padding, trailing: padding, bottom: padding)
    }
    
    /// anchor the view to the super view x and y axis if values are provided.
    ///
    /// - Parameters:
    ///   - xOffset: distacnce of view's center x from it's superview's center x. if nil the constraint is not created. default is 0
    ///   - yOffset: distacnce of view's center y from it's superview's center y. if nil the constraint is not created. default is 0
    /// - Returns: an array of the constraints that where created.
    @discardableResult func centerInSuperview(xOffset: CGFloat? = 0, yOffset: CGFloat? = 0) -> [NSLayoutConstraint] {
        
        guard let superview = self.superview else { return [] }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let xOffset = xOffset {
            let anchor = centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: xOffset)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let yOffset = yOffset {
            let anchor = centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: yOffset)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        return constraints
        
    }
    
    /// anchor the view to the super view x and y axis if values are provided.
    ///
    /// - Parameters:
    ///   - xOffset: distacnce of view's center x from it's superview's center x. if nil the constraint is not created. default is 0
    ///   - yOffset: distacnce of view's center y from it's superview's center y. if nil the constraint is not created. default is 0
    /// - Returns: an array of the constraints that where created.
    @discardableResult func centerWith(_ view: UIView, xOffset: CGFloat? = 0, yOffset: CGFloat? = 0) -> [NSLayoutConstraint] {
        
        guard let _ = self.superview else { return [] }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let xOffset = xOffset {
            let anchor = centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: xOffset)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let yOffset = yOffset {
            let anchor = centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yOffset)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        return constraints
        
    }
    
    
    /// set size anchors to the view
    @discardableResult func setSize(width: CGFloat?, height: CGFloat?) -> [NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        if let width = width {
            let anchor = widthAnchor.constraint(equalToConstant: width)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        if let height = height {
            let anchor = heightAnchor.constraint(equalToConstant: height)
            anchor.isActive = true
            constraints.append(anchor)
        }
        
        return constraints
        
    }
    
    /// set size proportionaly to super view
    @discardableResult func setSizeProportionaly(to view: UIView, widthMoltiplier: CGFloat = 1.0, heightMoltiplier: CGFloat = 1.0) -> [NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        
        let widthConstraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMoltiplier)
        widthConstraint.isActive = true
        constraints.append(widthConstraint)
        
        let heightConstraint = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: heightMoltiplier)
        heightConstraint.isActive = true
        constraints.append(heightConstraint)
        
        return constraints
    }
    
    /// set the view to a square size with the specified length.
    @discardableResult func setSize(_ length: CGFloat) -> [NSLayoutConstraint] {
        return setSize(width: length, height: length)
    }
    
    @discardableResult func setSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return setSize(width: size.width, height: size.height)
    }
    
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach {
            addSubview($0)
        }
    }
}

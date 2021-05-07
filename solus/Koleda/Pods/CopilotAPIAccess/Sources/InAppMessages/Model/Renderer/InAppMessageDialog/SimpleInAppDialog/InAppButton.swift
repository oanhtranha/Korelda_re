//
//  InAppButton.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation
import UIKit

class InAppButton: UIButton {

    typealias PopupDialogButtonAction = () -> Void


    /// The font and size of the button title
    var titleFont: UIFont? {
        get { return titleLabel?.font }
        set { titleLabel?.font = newValue }
    }
    
    /// The height of the button
    var buttonHeight: Int
    
    /// The title color of the button
    var titleColor: UIColor? {
        get { return self.titleColor(for: UIControl.State()) }
        set { setTitleColor(newValue, for: UIControl.State()) }
    }

    /// The background color of the button
    var buttonColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
    }
    
    /// Whether button should dismiss popup when tapped
    var dismissOnTap = true

    /// The action called when the button is tapped
    fileprivate(set) var buttonAction: PopupDialogButtonAction?

    
    // MARK: Initializers

    /*!
     Creates a button that can be added to the popup dialog

     - parameter title:         The button title
     - parameter action:        The action closure
     
     */
    init(title: String, height: Int = 58, textColor: UIColor, bdColor: UIColor, dismissOnTap: Bool = true, action: PopupDialogButtonAction?) {

        // Assign the button height
        buttonHeight = height
        
        // Assign the button action
        buttonAction = action

        super.init(frame: .zero)

        self.dismissOnTap = dismissOnTap
        
        
        /// Default appearance of the button
        let defaultTitleFont      = UIFont.SFProTextBoldFont(size: 18)
        
        // Default appearance
        cornerRadius = 6
        setTitleColor(textColor, for: UIControl.State())
        titleLabel?.font              = defaultTitleFont
        backgroundColor               = bdColor
        
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        
        // Set the button title
        setTitle(title, for: UIControl.State())
        
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        setupView()
        
    }

    func setupView() {
        let views = ["button": self]
        let metrics = ["buttonHeight": buttonHeight]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[button(buttonHeight)]", options: [], metrics: metrics, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override var isHighlighted: Bool {
        didSet {
            isHighlighted ? buttonHilightedAnimation(.out, 0.5) : buttonHilightedAnimation(.in, 1.0)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
             return titleLabel?.intrinsicContentSize ?? CGSize.zero
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        super.layoutSubviews()
    }
}

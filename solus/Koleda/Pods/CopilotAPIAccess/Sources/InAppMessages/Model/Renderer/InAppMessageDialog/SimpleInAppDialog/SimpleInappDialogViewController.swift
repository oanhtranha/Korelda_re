//
//  PopupDialogViewController.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import UIKit

class SimpleInappDialogViewController: UIViewController {

    var dismissDelegate : DismissDelegate?
    
    var standardView: SimpleInappDialogView {
       return view as! SimpleInappDialogView // swiftlint:disable:this force_cast
    }
    
    override func loadView() {
        super.loadView()
        let dialogView = SimpleInappDialogView(frame: .zero)
        dialogView.dismissDelegate = dismissDelegate
        view = dialogView
    }
}

extension SimpleInappDialogViewController {
    
    // MARK: - Setter / Getter
    
    // MARK: Content
    
    /// The dialog image
    var image: UIImage? {
        get { return standardView.imageView.image }
        set {
            standardView.imageView.image = newValue
        }
    }
    
    /// The title text of the dialog
    var titleText: String? {
        get { return standardView.titleLabel.text }
        set {
            standardView.titleLabel.text = newValue
        }
    }
    
    /// The message text of the dialog
    var messageText: String? {
        get { return standardView.messageLabel.text }
        set {
            standardView.messageLabel.text = newValue
        }
    }
    
    var buttons: [InAppButton] {
        get {
            return standardView.buttonStackView.arrangedSubviews as? [InAppButton] ?? []
        }
        set {
            guard newValue.count > 0 else { return }
            newValue.forEach { standardView.buttonStackView.addArrangedSubview( $0 ) }
        }
    }
    
    // MARK: Appearance
    
    /// The font and size of the title label
    var titleFont: UIFont {
        get { return standardView.titleFont }
        set {
            if messageText == nil {
                standardView.titleFont = UIFont.SFProTextBoldFont(size: 40) ?? UIFont.systemFont(ofSize: 40.0, weight: .bold)
            } else {
                standardView.titleFont = newValue
            }
        }
    }
    
    /// The color of the title label
    var titleColor: UIColor? {
        get { return standardView.titleLabel.textColor }
        set {
            standardView.titleColor = newValue
        }
    }
    
    /// The text alignment of the title label
    var titleTextAlignment: NSTextAlignment {
        get { return standardView.titleTextAlignment }
        set {
            standardView.titleTextAlignment = newValue
        }
    }
    
    /// The font and size of the body label
    var messageFont: UIFont {
        get { return standardView.messageFont}
        set {
            standardView.messageFont = newValue
        }
    }
    
    /// The color of the message label
    var messageColor: UIColor? {
        get { return standardView.messageColor }
        set {
            standardView.messageColor = newValue
        }
    }
    
    /// The text alignment of the message label
    var messageTextAlignment: NSTextAlignment {
        get { return standardView.messageTextAlignment }
        set {
            standardView.messageTextAlignment = newValue
        }
    }
    
    ///message background color
    
    var messageBackgroundColor: UIColor? {
        get { return standardView.componentBackgroundColor }
        set { standardView.componentBackgroundColor = newValue }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.verticalSizeClass == .regular {//portrait
            
            buttons.count == 3 ? (standardView.buttonStackView.axis = .vertical) : (standardView.buttonStackView.axis = .horizontal)
            standardView.fullStackView.axis = .vertical
            if image != nil {
                standardView.fullStackView.distribution = .fill
                standardView.imageHeightConstraint?.constant = 202
            }
            else {
                standardView.fullStackView.axis = .vertical
            }
            
            
        } else if traitCollection.verticalSizeClass == .compact {//landscape
            standardView.buttonStackView.axis = .horizontal
            
            if(buttons.count == 3) {
                standardView.fullStackView.axis = .vertical
            } else {
                standardView.fullStackView.axis = .horizontal
            }
            
            if image != nil {
                buttons.count == 3 ? (standardView.fullStackView.distribution = .fill) : (standardView.fullStackView.distribution = .fillEqually)
                buttons.count == 3 ? (standardView.imageHeightConstraint?.constant = 0) : (standardView.imageHeightConstraint?.constant = 282)
            } else {
                standardView.fullStackView.axis = .vertical
            }
        }
    }
}

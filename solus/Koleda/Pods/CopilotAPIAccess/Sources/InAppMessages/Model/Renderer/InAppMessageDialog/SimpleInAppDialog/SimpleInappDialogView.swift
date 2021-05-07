//
//  PopupDialogDefaultView.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation
import UIKit

/// The main view of the popup dialog
 class SimpleInappDialogView: UIView {

    var dismissDelegate :DismissDelegate?
    
    // MARK: - Appearance

    /// The font and size of the title label
    var titleFont: UIFont {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }

    /// The color of the title label
    var titleColor: UIColor? {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }

    /// The text alignment of the title label
    var titleTextAlignment: NSTextAlignment {
        get { return titleLabel.textAlignment }
        set { titleLabel.textAlignment = newValue }
    }

    /// The font and size of the body label
    var messageFont: UIFont {
        get { return messageLabel.font }
        set { messageLabel.font = newValue }
    }

    /// The color of the message label
    var messageColor: UIColor? {
        get { return messageLabel.textColor }
        set { messageLabel.textColor = newValue}
    }

    /// The text alignment of the message label
    var messageTextAlignment: NSTextAlignment {
        get { return messageLabel.textAlignment }
        set { messageLabel.textAlignment = newValue }
    }
    
    var componentBackgroundColor: UIColor? {
        get { return componentContainer.backgroundColor }
        set { componentContainer.backgroundColor = newValue }
    }

    // MARK: - Views

    /// The view that will contain the image, if set
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    /// The title label of the dialog
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        titleLabel.font = UIFont.SFProTextBoldFont(size: 24)
        return titleLabel
    }()

    /// The message label of the dialog
    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(frame: .zero)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
        messageLabel.font = UIFont.SFProTextRegularFont(size: 22)
        return messageLabel
    }()
    
    lazy var labelsStackView: UIStackView = {
        let labelsStackView = UIStackView()
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.distribution = .fill
        labelsStackView.alignment = .fill
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        return labelsStackView
    }()
    
    // The container stack view for buttons
    lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 15
        return buttonStackView
    }()
    
    lazy var fullStackView: UIStackView = {
        let fullStackView = UIStackView()
        fullStackView.translatesAutoresizingMaskIntoConstraints = false
        fullStackView.distribution = .fill
        fullStackView.axis = .vertical
        fullStackView.spacing = 0
        return fullStackView
    }()
        
    lazy var componentContainer: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        return container
    }()
    
    lazy var buttonsContainer: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        return container
    }()
    
    lazy var dismissButton: UIView = {
        let image = UIImage(named: "clear", in: Bundle(for: Copilot.self), compatibleWith: nil) as UIImage?
        let button = UIButton(type: .custom) as UIButton
        button.backgroundColor = .none
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .top
        
        button.addTarget(self, action: #selector(dismissPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc func dismissPressed(_ sender:UIButton){
        self.dismissDelegate?.dismissPoup()
    }
    
    /// The height constraint of the image view, 0 by default
    var imageHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    private func setupViews() {

        // Self setup
        translatesAutoresizingMaskIntoConstraints = false

        // Add views
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(messageLabel)
        
        buttonsContainer.addSubview(buttonStackView)
        labelsStackView.addArrangedSubview(buttonsContainer)
        componentContainer.addSubview(labelsStackView)
        
        fullStackView.addArrangedSubview(imageView)
        fullStackView.addArrangedSubview(componentContainer)
        addSubview(fullStackView)
        addSubview(dismissButton)
        
        // Layout views
        var constraints = [NSLayoutConstraint]()

        fullStackView.anchorToSuperview()
        dismissButton.anchorToSuperview(top:6, leading: nil, trailing: 6, bottom: nil )
        
        labelsStackView.anchorToSuperview(top: 29, leading: 15, trailing: 20, bottom: 16)
        
        labelsStackView.centerInSuperview()

        buttonStackView.anchorToSuperview()
        
        // ImageView height constraint
        imageHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 0, constant: 0)
        
        if let imageHeightConstraint = imageHeightConstraint {
            constraints.append(imageHeightConstraint)
        }

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
        
        fullStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: CGFloat(27)).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: CGFloat(27)).isActive = true
    }
}

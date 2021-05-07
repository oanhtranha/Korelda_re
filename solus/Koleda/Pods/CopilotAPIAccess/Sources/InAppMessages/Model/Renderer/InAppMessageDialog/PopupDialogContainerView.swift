//
//  PopupDialogContainerView.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation
import UIKit

/// The main view of the popup dialog
class PopupDialogContainerView: UIView {

    // MARK: - Appearance

    /// The background color of the popup dialog
    override var backgroundColor: UIColor? {
        get { return container.backgroundColor }
        set { container.backgroundColor = newValue }
    }

    /// The corner radius of the popup view
    override var cornerRadius: CGFloat {
        get { return CGFloat(shadowContainer.layer.cornerRadius) }
        set {
            let radius = CGFloat(newValue)
            shadowContainer.layer.cornerRadius = radius
            container.layer.cornerRadius = radius
        }
    }
    
    // MARK: Shadow related

    /// Enable / disable shadow rendering of the container
    var shadowEnabled: Bool {
        get { return shadowContainer.layer.shadowRadius > 0 }
        set { shadowContainer.layer.shadowRadius = newValue ? shadowRadius : 0 }
    }

    /// Color of the container shadow
    var shadowColor: UIColor? {
        get {
            guard let color = shadowContainer.layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set { shadowContainer.layer.shadowColor = newValue?.cgColor }
    }
    
    /// Radius of the container shadow
    var shadowRadius: CGFloat {
        get { return shadowContainer.layer.shadowRadius }
        set { shadowContainer.layer.shadowRadius = newValue }
    }
    
    /// Opacity of the the container shadow
    var shadowOpacity: Float {
        get { return shadowContainer.layer.shadowOpacity }
        set { shadowContainer.layer.shadowOpacity = newValue }
    }
    
    /// Offset of the the container shadow
    var shadowOffset: CGSize {
        get { return shadowContainer.layer.shadowOffset }
        set { shadowContainer.layer.shadowOffset = newValue }
    }
    
    /// Path of the the container shadow
    var shadowPath: CGPath? {
        get { return shadowContainer.layer.shadowPath }
        set { shadowContainer.layer.shadowPath = newValue }
    }
    
    // MARK: - Views

    /// The shadow container is the basic view of the PopupDialog
    /// As it does not clip subviews, a shadow can be applied to it
    lazy var shadowContainer: UIView = {
        let shadowContainer = UIView(frame: .zero)
        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = UIColor.clear
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowRadius = 6
        shadowContainer.layer.shadowOpacity = 0.4
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowContainer.layer.cornerRadius = 4
        return shadowContainer
    }()

    /// The container view is a child of shadowContainer and contains
    /// all other views. It clips to bounds so cornerRadius can be set
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white
        container.clipsToBounds = true
        container.layer.cornerRadius = 4.5
        return container
    }()

    // The main stack view, containing all relevant views
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    
    
    // The preferred width for iPads
    fileprivate let preferredWidth: CGFloat
    
    private let inAppMessageType: InAppMessageType

    // MARK: - Constraints

    /// The center constraint of the shadow container
    
    var centerYConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    
    init(frame: CGRect, preferredWidth: CGFloat, inAppMessageType: InAppMessageType) {
        self.preferredWidth = preferredWidth
        self.inAppMessageType = inAppMessageType
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    func setupViews() {

        // Add views
        addSubview(shadowContainer)
        shadowContainer.addSubview(container)
        container.addSubview(mainStackView)
        
        // Layout views
        let views = ["shadowContainer": shadowContainer, "container": container, "stackView": mainStackView]
        
        var constraints = [NSLayoutConstraint]()

        // Shadow container constraints
        shadowContainer.centerWith(self)

        //iPad devices shadow container layout
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            let metrics = ["preferredWidth": preferredWidth]
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=40)-[shadowContainer(==preferredWidth@900)]-(>=40)-|", options: [], metrics: metrics, views: views)
            if case .html = inAppMessageType {
                shadowContainer.setSizeProportionaly(to: self, widthMoltiplier: 0.5, heightMoltiplier: 0.6)
            }

        }

        //iPhone devices shadow container layout
        else {
            switch inAppMessageType {
            case .html:
                shadowContainer.setSizeProportionaly(to: self, widthMoltiplier: 0.9, heightMoltiplier: 0.85)
            case .simple, .nps:
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=42,==20@900)-[shadowContainer(<=700,==330@900)]-(>=42,==20@900)-|", options: [], metrics: nil, views: views)
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=20)-[shadowContainer]-(>=20)-|", options: [], metrics: nil, views: views)
            }
        }
        
        
        if let centerYConstraint = centerYConstraint {
            constraints.append(centerYConstraint)
        }

        // Main stack view constraints
        if case .html = inAppMessageType {
            mainStackView.anchorToSuperview(padding: 10)
        } else {
            mainStackView.anchorToSuperview(padding: 0)
        }
        // Container constraints
        container.anchorToSuperview()

        // Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
}

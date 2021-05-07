//
//  LoadingViewController.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 13/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    // MARK: - Properties
    
    private let darkOverlayView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        activityIndicatorView.stopAnimating()
    }
    
    
    // MARK: - Private Functions
    
    private func setupUI() {
        self.view.backgroundColor = .loadingViewBackgroundColor
        
        darkOverlayView.frame = self.view.bounds
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.view.addSubview(darkOverlayView)
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        activityIndicatorView.color = .activityIndicatorColor
    }
}


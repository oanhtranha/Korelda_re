//
//  UIViewController+LoadingView.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 13/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

internal extension UIViewController {
    
    func showLoadingView(animated: Bool = true, completion: (() -> ())? = nil) {
        let loadingVC = LoadingViewController()
        
        DispatchQueue.main.async {
            loadingVC.willMove(toParent: self)
            loadingVC.view.alpha = 0
            self.view.addSubview(loadingVC.view)
            loadingVC.view.translatesAutoresizingMaskIntoConstraints = false
            loadingVC.view.addConstraintsToSizeToParent()
            self.addChild(loadingVC)
            loadingVC.didMove(toParent: self)
            
            UIView.transition(with: loadingVC.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                loadingVC.view.alpha = 1
            }, completion: { (finsished) in
                completion?()
            })
        }
    }
    
    func hideLoadingView(animated: Bool = true, completion: (() -> ())? = nil) {
        if let loadingVC = (children.compactMap { $0 as? LoadingViewController }).first {
            DispatchQueue.main.async {
                loadingVC.willMove(toParent: nil)
                UIView.transition(with: loadingVC.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    loadingVC.view.alpha = 0
                }, completion: { (finsished) in
                    loadingVC.view.removeFromSuperview()
                    loadingVC.removeFromParent()
                    completion?()
                })
            }
        } else {
            completion?()
        }
    }
    
}

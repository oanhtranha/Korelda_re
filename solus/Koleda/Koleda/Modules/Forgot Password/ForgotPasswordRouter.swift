//
//  ForgotPasswordRouter.swift
//  Koleda
//
//  Created by Oanh tran on 6/20/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ForgotPasswordRouter: BaseRouterProtocol {
    weak var baseViewController: UIViewController?
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }
        
        baseViewController.navigationController?.popViewController(animated: animated)
    }
}

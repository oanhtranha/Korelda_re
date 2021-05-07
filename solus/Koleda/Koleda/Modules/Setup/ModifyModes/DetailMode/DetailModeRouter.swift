//
//  DetailModeRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 2/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import UIKit

class DetailModeRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case backModifyModes
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }

        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }

        switch routeType {
        case .backModifyModes:
            baseViewController.navigationController?.popViewController(animated: false)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}

//
//  EditSensorRouter.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class EditSensorRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case backHome
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
        case .backHome:
            baseViewController.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        
    }
    
}

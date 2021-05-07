//
//  ManualBoostRouter.swift
//  Koleda
//
//  Created by Oanh tran on 8/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class ManualBoostRouter: BaseRouterProtocol {
    
    enum RouteType {
    }

    weak var baseViewController: UIViewController?

    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }
        
        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }
    }

    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }

    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
    }


}

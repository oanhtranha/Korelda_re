//
//  HeatersManagementRouter.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class HeatersManagementRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case backHome
        case done
        case addHeaterFlow(String, String)
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
        case .done:
            baseViewController.navigationController?.popViewController(animated: true)
        case .addHeaterFlow(let roomId, let roomName):
            baseViewController.gotoBlock(withStoryboar: "Heater", aClass: InstructionForHeaterViewController.self, sendData: { (vc) in
                vc?.roomId = roomId
                vc?.roomName = roomName
                vc?.isFromRoomConfiguration = true
            })
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        
    }
    
}

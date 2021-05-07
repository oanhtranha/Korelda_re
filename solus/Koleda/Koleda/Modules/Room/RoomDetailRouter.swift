//
//  RoomDetailRouter.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class RoomDetailRouter: BaseRouterProtocol {
   
    enum RouteType {
        case deleted
        case added(String, String)
        case updated
    }
    
    weak var baseViewController: UIViewController?
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }
        
        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }
        
        switch routeType {
        case .added:
            baseViewController.navigationController?.popToRootViewController(animated: animated)
        case .updated:
            baseViewController.navigationController?.popToRootViewController(animated: animated)
        case .deleted:
            baseViewController.navigationController?.popToRootViewController(animated: animated)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
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
        case .added(let roomId, let roomName):
            baseViewController.gotoBlock(withStoryboar: "Sensor", aClass: InstructionViewController.self, sendData: { (vc) in
                vc?.roomId = roomId
                vc?.roomName = roomName
            })
        default:
            break
        }
        
    }
    
}

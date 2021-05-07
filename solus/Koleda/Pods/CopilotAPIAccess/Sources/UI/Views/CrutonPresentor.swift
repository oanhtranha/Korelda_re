//
//  CrutonPresentor.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

enum CrutonPresentationPosition {
    case top
    case bottom
}

struct CrutonModel {
    let backgroundColor: UIColor
    let crutonHeight: CGFloat
    let textString: String
    let textColor: UIColor
    let presentationPosition: CrutonPresentationPosition
}

class CrutonPresentor {
    
    private var outOfScreenYPosition: CGFloat = 0
    
    private struct Consts {
        static let screenWidth = UIScreen.main.bounds.size.width
        static let screenHeight = UIScreen.main.bounds.size.height
    }
    
    var currentlyPresentedCruton: CrutonModel?
    
    init() {
        //No initializers
    }
    
    func presentCruton(with crutonModel: CrutonModel, fromVC: UIViewController? = nil) {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            ZLogManagerWrapper.sharedInstance.logError(message: "App has no root VC")
            return
        }
    
        guard currentlyPresentedCruton == nil else {
            return
        }
        currentlyPresentedCruton = crutonModel
        
        let topVC = fromVC ?? getTopController(for: rootVC)
        
        let crutonHeight: CGFloat = crutonModel.crutonHeight
        
        //Consts
        let crutonLabelPadding: CGFloat = 25.0
        
        //Set the origin and final Y position
        var finalYPos: CGFloat
        switch crutonModel.presentationPosition {
        case .bottom:
            if let tabBarController = topVC as? UITabBarController {
                self.outOfScreenYPosition = tabBarController.tabBar.frame.origin.y
                finalYPos = outOfScreenYPosition - crutonHeight
            }
            else {
                self.outOfScreenYPosition = topVC.view.frame.height
                finalYPos = outOfScreenYPosition - crutonHeight
            }
            
        case .top:
            let stausBarHeight = UIApplication.shared.statusBarFrame.size.height
            self.outOfScreenYPosition = topVC.view.bounds.height - Consts.screenHeight - crutonHeight
            finalYPos = topVC.view.bounds.height - Consts.screenHeight + stausBarHeight
            
            if let navigationController = topVC.navigationController, !navigationController.isNavigationBarHidden  {
                finalYPos += navigationController.navigationBar.bounds.height
            }
        }
        
        //Apply crutonView
        let crutonView = UIView.init(frame: CGRect(x: 0.0, y: outOfScreenYPosition, width: Consts.screenWidth, height: crutonHeight))
        crutonView.backgroundColor = crutonModel.backgroundColor
        
        //Apply shadow
        crutonView.layer.shadowColor = UIColor.black.cgColor
        crutonView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        crutonView.layer.shadowRadius = 5.0
        crutonView.layer.shadowOpacity = 0.5
        
        //Apply label
        let crutonLabel = UILabel.init(frame: CGRect(x: crutonLabelPadding, y: 0.0, width: Consts.screenWidth - crutonLabelPadding * 2, height: crutonHeight))
        if let font = UIFont.SFProTextRegularFont(size: 12) {
            crutonLabel.font = font
        }
        crutonLabel.textColor = crutonModel.textColor
        crutonLabel.text = crutonModel.textString
        crutonLabel.backgroundColor = UIColor.clear
        crutonLabel.numberOfLines = 2
        crutonLabel.textAlignment = .center
        
        DispatchQueue.main.async {
            
            crutonView.addSubview(crutonLabel)
            
            if let tabBarController = topVC as? UITabBarController {
                tabBarController.view.insertSubview(crutonView, belowSubview: tabBarController.tabBar)
            }
            else {
                topVC.view.addSubview(crutonView)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseOut], animations: {
                crutonView.frame = CGRect(x: 0.0, y: finalYPos, width: Consts.screenWidth, height: crutonHeight)
            }){ (complete: Bool) in
                UIView.animate(withDuration: 0.3, delay: 2, options: [.curveEaseInOut], animations: { [weak self] in
                    crutonView.frame = CGRect(x: 0.0, y: self?.outOfScreenYPosition ?? -crutonHeight, width: Consts.screenWidth, height: crutonHeight)
                }, completion: { (completed: Bool) in
                    if crutonView.superview != nil {
                        crutonView.removeFromSuperview()
                    }
                    
                    self.currentlyPresentedCruton = nil
                })
            }
        }
    }
    
    private func getTopController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return getTopController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController, let pushedViewController = navigationController.viewControllers.last {
            return getTopController(for: pushedViewController)
        } else if let tabBarController = controller as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return getTopController(for: selectedViewController)
        } else {
            return controller
        }
    }
    
}

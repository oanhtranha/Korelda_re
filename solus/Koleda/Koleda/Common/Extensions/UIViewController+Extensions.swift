//
//  UIViewController+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    func app_removeFromContainerView() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    var top: UIViewController? {
        if let controller = self as? UINavigationController {
            return controller.topViewController?.top
        }
        if let controller = self as? UISplitViewController {
            return controller.viewControllers.last?.top
        }
        if let controller = self as? UITabBarController {
            return controller.selectedViewController?.top
        }
        if let controller = presentedViewController {
            return controller.top
        }
        return self
    }
}

extension UIBarButtonItem {
    
    class var back_empty: UIBarButtonItem {
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}


public typealias Identifier = String

public protocol Identifiable: class  {
    static var get_identifier: Identifier { get }
}

public extension Identifiable {
    static var get_identifier: Identifier {
        return String(describing: self)
    }
}
extension UIViewController: Identifiable {}
extension UITableViewCell: Identifiable {}

extension UIViewController {
    
    func goto(withStoryboar fileName: String, present isPresent: Bool = false) {
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            if (!isPresent) {
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func goto(withStoryboar fileName: String, present isPresent: Bool = false, finish isFinish: Bool = false) {
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            if (!isPresent) {
                self.navigationController?.pushViewController(controller, animated: true)
                if isFinish == true {
                    self.navigationController?.popViewController(animated: false)
                }
            } else {
                self.present(controller, animated: true) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func goto(withStoryboar fileName: String, withIndentifier indentifier: String, present isPresent: Bool = false ) {
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: indentifier)
        if (!isPresent) {
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func gotoBlock<T: UIViewController>(withStoryboar fileName: String, aClass: T.Type, present isPresent: Bool = false, sendData: ((T?) -> Swift.Void)) {
        let className = String(describing: aClass)
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        let controller: T = storyboard.instantiateViewController(withIdentifier: className) as! T
        if (!isPresent) {
            if self.navigationController?.viewControllers.last != self {
                return
            }
            sendData(controller)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func goto(withIdentifier seque: String, sender: Any? = nil) {
        self.performSegue(withIdentifier: seque, sender: sender)
    }
    
    func getViewControler<T: UIViewController>(withStoryboar fileName: String? = nil, aClass: T.Type) -> T? {
        let className = String(describing: aClass)
        var storyboard: UIStoryboard? = nil
        if fileName == nil {
            storyboard = self.storyboard
        } else {
            storyboard = UIStoryboard(name: fileName!, bundle: nil)
        }
        if storyboard != nil {
            let controller: T? = storyboard!.instantiateViewController(withIdentifier: className) as? T
            return controller
        } else {
            return nil
        }
    }
    
    func getViewControler(withStoryboar fileName: String, identifier: String? = nil) -> UIViewController? {
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if identifier != nil {
            let controller: UIViewController? = storyboard.instantiateViewController(withIdentifier: identifier!) as? UIViewController
            return controller
        } else {
            if let controller = storyboard.instantiateInitialViewController() {
                return controller
            } else {
                let controller: UIViewController? = storyboard.instantiateViewController(withIdentifier: "UINavigationController") as? UIViewController
                return controller
            }
        }
    }
    
    static func getNavigationController<T: UIViewController>(withStoryboar fileName: String, aClass: T.Type) -> UINavigationController {
        let className = String(describing: aClass)
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: className)
        let navcl = UINavigationController()
        navcl.viewControllers = [vc] as! [UIViewController]
        return navcl
    }
    
    func back(animated: Bool = true, isDismiss: Bool = false) {
        if (isDismiss) {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: false)
        } else if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: animated)
        } else {
            self.dismiss(animated: animated)
        }
    }
    
    func backToViewControler(viewController: AnyClass, animated: Bool = true) {
        if let navigationController = self.navigationController {
            for var vc in navigationController.viewControllers {
                if vc.isKind(of: viewController) {
                    navigationController.popToViewController(vc, animated: animated)
                    return
                }
            }
            navigationController.popToRootViewController(animated: animated)
        }
    }
    
    func backToRoot(animated: Bool = true) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: animated)
        }
    }
    
    func backPresentRight(withStoryboar fileName: String, withIndentifier indentifier: String? = nil) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if let indentifier = indentifier {
            let controller = storyboard.instantiateViewController(withIdentifier: indentifier)
            present(controller, animated: false, completion: nil)
        } else {
            if let controller = storyboard.instantiateInitialViewController() {
                present(controller, animated: false, completion: nil)
            }
        }
    }
    
    func gotoPresentLeft(withStoryboar fileName: String, withIndentifier indentifier: String? = nil) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if let indentifier = indentifier {
            let controller = storyboard.instantiateViewController(withIdentifier: indentifier)
            present(controller, animated: false, completion: nil)
        } else {
            if let controller = storyboard.instantiateInitialViewController() {
                present(controller, animated: false, completion: nil)
            }
        }
    }
    
    func gotoPresentLeft<T: UIViewController>(withStoryboar fileName: String? = nil, aClass: T.Type, sendData: ((T?) -> Swift.Void)) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        //        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        if let controller = getViewControler(withStoryboar: fileName, aClass: aClass) {
            sendData(controller)
            present(controller, animated: false, completion: nil)
        }
    }
    
    class func getRoot() -> UIViewController {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let viewController = appDelegate.window!.rootViewController as! UIViewController
        return viewController;
    }
    
    class func setRoot(withStoryboar fileName: String, identifier: String) {
        let storyboard = UIStoryboard(name: fileName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        
        if let window = appDelegate.window {
            window.rootViewController = controller
            window.backgroundColor = UIColor.white
            window.makeKeyAndVisible()
        }
    }
    
    class func getVisibleViewController(_ _rootViewController: UIViewController? = nil) -> UIViewController? {
        
        var rootViewController = _rootViewController
        if rootViewController == nil {
            rootViewController = getRoot()
        }
        
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if let presented = rootViewController?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            } else if presented.isKind(of: UITabBarController.self){
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    
    func showPopup(_ vc: UIViewController, transitionStyle: UIModalTransitionStyle = .crossDissolve, animated: Bool = true) {
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = transitionStyle
        vc.definesPresentationContext = true
        present(vc, animated: animated, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
}

protocol NameDescribable {
    var screenName: String { get }
    static var screenName: String { get }
}

extension NameDescribable {
    var screenName: String {
        return String(describing: type(of: self))
    }
    
    static var screenName: String {
        return String(describing: self)
    }
}

extension NSObject: NameDescribable {}
extension UIViewController: NameDescribable {}

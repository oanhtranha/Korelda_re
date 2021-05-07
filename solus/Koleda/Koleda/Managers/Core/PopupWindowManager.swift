//
//  PopupWindowManager.swift
//  Koleda
//
//  Created by Oanh tran on 8/19/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

typealias KLDCloseHandler = () -> Void

protocol Popup: class {
    func show(in viewController: UIViewController, animated: Bool, closeHandler: KLDCloseHandler?)
    func hide(animated: Bool, completion: KLDCloseHandler?)
}

class PopupWindowManager {
    
    var isShown: Bool {
        return popup != nil
    }
    
    func show(popup: Popup) {
        guard !isShown else {
            popupWindow?.makeKeyAndVisible()
            return
        }
        
        popupWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        guard let popupContainerWindow = popupWindow else {
            return
        }
        popupContainerWindow.backgroundColor = .clear
        popupContainerWindow.windowLevel = UIWindow.Level.normal
        let rootViewController = PassthroughViewController()
        popupContainerWindow.rootViewController = rootViewController
        
        popup.show(in: rootViewController, animated: true, closeHandler: removePopupContainerWindow)
        self.popup = popup
        
        popupContainerWindow.makeKeyAndVisible()
    }
    
    func hide(popup: Popup, completion: KLDCloseHandler? = nil) {
        if popup === self.popup {
            popup.hide(animated: true, completion: completion)
        }
    }
    
    // MARK: - Implementation
    
    private var popupWindow: UIWindow?
    private var popup: Popup?
    
    private func removePopupContainerWindow() {
        popup = nil
        popupWindow?.rootViewController = nil
        popupWindow = nil
        
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    }
}


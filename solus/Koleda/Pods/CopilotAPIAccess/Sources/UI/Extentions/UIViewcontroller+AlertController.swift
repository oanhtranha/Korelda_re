//
//  UIViewcontroller+AlertController.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

public typealias PopupActionClosure = () -> ()

internal extension UIViewController {
    
    public func presentAlertControllerWithPopupRepresentable(_ popupRepresentable: PopupRepresentable, cancelButtonText: String,  actionButtonText: String? = nil, cancelCompletionHandler: PopupActionClosure? = nil, actionCompletionHandler: PopupActionClosure? = nil) {
        let alertController = UIAlertController(title: popupRepresentable.title, message: popupRepresentable.message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel, handler: { (action) in
            cancelCompletionHandler?()
        })
        alertController.addAction(cancelAction)
        
        if let actionButtonText = actionButtonText {
            let action = UIAlertAction(title: actionButtonText, style: .default, handler: { (action) in
                actionCompletionHandler?()
            })
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

//
//  UIViewController+Alerts.swift
//  Koleda
//
//  Created by Oanh tran on 7/8/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func app_showAlertMessage(title: String?, message: String?, actions:[UIAlertAction]? = nil) {
        let alertContoller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if actions?.compactMap({alertContoller.addAction($0)}) == nil {
            let okAction = UIAlertAction(title: "OK".app_localized, style: .default, handler: nil)
            alertContoller.addAction(okAction)
        }
        present(alertContoller, animated: true, completion: nil)
    }
    
    func app_showInfoAlert(_ message: String,
                          title: String? = nil,
                          completion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK".app_localized,
                                          style: .default,
                                          handler: { (action) in
                                            if let handler = completion {
                                                handler()
                                            }
        })
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func app_showPromptAlert(title: String? = nil,
                            message: String, acceptTitle: String?,
                            dismissTitle: String?,
                            acceptButtonStyle: UIAlertAction.Style = .cancel,
                            acceptCompletion: (() -> Void)? = nil,
                            dismissCompletion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let acceptTitle = acceptTitle {
            let acceptAction = UIAlertAction(title: acceptTitle, style: acceptButtonStyle) { (alertAction) in
                if let action = acceptCompletion {
                    action()
                }
            }
            
            alertController.addAction(acceptAction)
        }
        
        if let dismissTitle = dismissTitle {
            let dismissAction = UIAlertAction(title: dismissTitle, style: .default) { (alertAction) in
                if let action = dismissCompletion {
                    action()
                }
            }
            
            alertController.addAction(dismissAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func app_showActionSheet(title: String? = nil,
                            message: String? = nil,
                            preferredStyle: UIAlertController.Style = .actionSheet,
                            actionTitles: [String],
                            actionStyles: [UIAlertAction.Style],
                            withHandler handlers: [((UIAlertAction) -> Void)?]) {
        
        guard !actionTitles.isEmpty, actionStyles.count == actionTitles.count, handlers.count == actionTitles.count else { return }
        
        let actionSheetController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actionTitles.enumerated().forEach { (index, element) in
            actionSheetController.addAction(UIAlertAction(title: element,
                                                          style: actionStyles[index],
                                                          handler: handlers[index]))
        }
        
        present(actionSheetController, animated: true, completion: nil)
    }
}

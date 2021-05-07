//
//  Renderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol Renderer {
    func render(reporter: InAppReporter, iamReport: InAppMessageReport, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ()) 
    func verifyConditions() -> Bool
}

extension Renderer {
    
    func verifyConditions() -> Bool {
        return !checkIfAlertViewOrActivityViewHasPresented() && checkIfApplicationStateIsActive() && !KeyboardStateListener.shared.isVisible
    }
    
    //MARK: - private
    private func checkIfAlertViewOrActivityViewHasPresented() -> Bool {

        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController is UIAlertController || topController is UIActivityViewController || topController is PopupDialog
        }
        return false
    }
    
    private func checkIfApplicationStateIsActive() -> Bool {
        var returnValue = false
        switch UIApplication.shared.applicationState {
        case .background , .inactive:
            returnValue = false
        case .active:
            returnValue = true
        default:
            break
        }
        return returnValue
    }
}

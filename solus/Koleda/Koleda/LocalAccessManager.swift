//
//  LocalAccessManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class LocalAccessManager {
    
    var isBiometricIDAvailable: Bool {
        let context = LAContext()
        return isBiometricIDAvailable(context: context)
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        guard isBiometricIDAvailable(context: context) else {
            return .none
        }
        
        if #available(iOS 11.0, *), context.responds(to: #selector(getter: LAContext.biometryType)) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return .touchID
        }
    }
    
    // MARK: - Public methods
    
    func authenticateUsingBiometricID(success: @escaping () -> Void, failure: @escaping (_ errorDescription: String) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = NSLocalizedString("Enter Passcode", comment: "")
        let reasonString = "Access required for authentication with fingerprint".app_localized
        log.info("Start authentication using BiometricID")
        if isBiometricIDAvailable(context: context) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (isSuccess, policyError) in
                log.info("Authentication using BiometricID is completed")
                if isSuccess {
                    log.info("BiometricID was recognized")
                    success()
                } else {
                    if let error = policyError {
                        log.error("BiometricID NOT was recognized, error: \(error.localizedDescription))")
                    }
                    failure(policyError?.localizedDescription ?? NSLocalizedString("Some error appeared", comment: "Unknown error appeared"))
                }
            })
        } else {
            failure("BiometricID is NOT supported by the device")
        }
    }
    
//    func canAuthentificate(withPin pin: String) -> Bool {
//        guard let pinFromKeychain = Pin.restore() else {
//            return false
//        }
//        
//        return pinFromKeychain == pin
//    }
    
    // MARK: - Private methods
    
    /*
     As per Apple answer at https://forums.developer.apple.com/thread/89043:
     "You need to first call canEvaluatePolicy in order to get the biometry type."
     */
    private func isBiometricIDAvailable(context: LAContext) -> Bool {
        var error: NSError?
        log.info("Check if device support BiometricID")
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            log.info("BiometricID is supported by the device")
            return true
        }
        if let error = error {
            log.info("BiometricID is NOT supported by the device, error description: \(error.localizedDescription)")
        }
        return false
    }
}




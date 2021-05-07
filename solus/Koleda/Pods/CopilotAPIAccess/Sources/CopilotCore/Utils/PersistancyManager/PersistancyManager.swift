//
//  PersistancyManager.swift
//  GreenRide-Inu
//
//  Created by Miko Halevi on 7/26/17.
//  Copyright © 2017 Miko Halevi. All rights reserved.
//

import Foundation
import CopilotLogger

enum PersistancyManagerError : Error {
    case bundleIdNotFound
}

struct PersistancyManager {
    
    //MARK: Keychain
    
    static func setSecured(string: String, key: String) -> Error? {
        do {
            let keychainManager = KeychainPasswordItem(service:try PersistancyManager.getBundleIdentifier(), account: key)
            try keychainManager.savePassword(string)
        }
        catch {
            ZLogManagerWrapper.sharedInstance.logError(message: "set secured string failed with error: \(error)")
            return error
        }
        
        return nil
    }
    
    static func getSecuredString(withKey key: String) -> Response<String?, PersistancyError> {
        do {
            let keychainManager = KeychainPasswordItem(service:try PersistancyManager.getBundleIdentifier(), account: key)
            let securedString =  try keychainManager.readPassword()
            return .success(securedString)
        }
        catch {
            ZLogManagerWrapper.sharedInstance.logDebug(message: "get secured string failed with error: \(error)")
            
            if let keychainError = error as? KeychainPasswordItem.KeychainError {
                switch keychainError {
                case .noPassword, .unexpectedItemData, .unexpectedPasswordData:
                    return .success(nil)
                case .unhandledError(_):
                    break
                }
            }
        
            return .failure(error: .generalError(error))
        }
        
    }
    
    static func deleteSecuredString(withKey key: String) -> Error? {
        do {
            let keychainManager = KeychainPasswordItem(service:try PersistancyManager.getBundleIdentifier(), account: key)
            try keychainManager.deleteItem()
        }
        catch {
            ZLogManagerWrapper.sharedInstance.logError(message: "delete secured string failed with error: \(error)")

            return error
        }
        
        return nil
    }
    
    //MARK: UserDefaults
    
    static func setGeneral(item: Any, key: String) {
        let itemAsData = NSKeyedArchiver.archivedData(withRootObject: item)
        UserDefaults.standard.set(itemAsData, forKey: key)
    }
    
    static func getGeneralItem(withKey key: String) -> Any? {
        if let objectAsData = UserDefaults.standard.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: objectAsData)
        }
        
        ZLogManagerWrapper.sharedInstance.logDebug(message: "Fetching general item - could not find key: \(key)")
        return nil
    }
    
    static func deleteGeneralItem(withKey key: String) {
        UserDefaults.standard.set(nil, forKey: key)
    }
    
    //MARK: Private helpers
    
    private static func getBundleIdentifier() throws -> String {
        if let bundleId = Bundle.main.bundleIdentifier {
                return bundleId
        }
        throw PersistancyManagerError.bundleIdNotFound
    }
    
}

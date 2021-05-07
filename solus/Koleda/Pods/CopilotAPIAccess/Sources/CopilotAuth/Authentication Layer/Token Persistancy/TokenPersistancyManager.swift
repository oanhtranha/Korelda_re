//
//  TokenPersistancyManager.swift
//  GreenRide-Inu
//
//  Created by Miko Halevi on 8/6/17.
//  Copyright © 2017 Miko Halevi. All rights reserved.
//

import Foundation
import CopilotLogger

class TokenPersistancyManager: TokenPersistancyProtocol {
    
    private struct Constants  {
        static let refreshTokenKey = "refreshTokenKey"
        static let initKey = "TokenPersistancyManagerDidRun"
    }
    
    static let sharedInstance = TokenPersistancyManager()
    
    private init() {
        let wasInitiated = PersistancyManager.getGeneralItem(withKey: Constants.initKey)
        if wasInitiated == nil {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "First initialization of TokenPersistancyManager since installation. Verifying that there are no leftovers of a token in keychain")
            if let error = PersistancyManager.deleteSecuredString(withKey: Constants.refreshTokenKey){
                ZLogManagerWrapper.sharedInstance.logError(message: "Failed deleting refresh token from key chain \(error.localizedDescription)")
            }
            PersistancyManager.setGeneral(item: "YES", key: Constants.initKey)
        }
    }
    
    func saveToken(_ token: Token) -> Error? {
        return PersistancyManager.setSecured(string: token, key: Constants.refreshTokenKey)
    }
    
    func getToken() -> Response<String?, PersistancyError> {
        return PersistancyManager.getSecuredString(withKey: Constants.refreshTokenKey)
    }
    
    func deleteToken() -> Error? {
        return PersistancyManager.deleteSecuredString(withKey: Constants.refreshTokenKey)
    }
    
}

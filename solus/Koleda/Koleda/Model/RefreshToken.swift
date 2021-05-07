//
//  RefreshToken.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Locksmith

struct RefreshToken {
    
    static func store(_ token: String) throws {
        // Deletion needed for the case when a refresh token with different accessible option is already present in the
        // keychain. In that case updating it fails with a duplication error.
        try? delete()
        try Locksmith.app_updateData(data: ["refreshToken": token],
                                    forUserAccount: userAccountKey,
                                    inService: keychainService,
                                    accessibleOption: .alwaysThisDeviceOnly)
        log.info("Stored refresh token")
    }
    
    static func restore() -> String? {
        if let tokenInfo = Locksmith.loadDataForUserAccount(userAccount: userAccountKey, inService: keychainService) {
            log.info("Retrieved refresh token info")
            return tokenInfo["refreshToken"] as? String
        } else {
            log.error("Can't retrieve refresh token")
            return nil
        }
    }
    
    static func isStored() -> Bool {
        return restore() != nil
    }
    
    static func delete() throws {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userAccountKey, inService: keychainService)
            log.info("Deleted refresh token")
        } catch LocksmithError.notFound {
            log.debug("Item to be deleted is not present in keychain")
        }
    }
    
    // MARK: - Implementation
    
    private static let userAccountKey = "user.current.account"
    private static let keychainService = "com.koleda.refreshToken"
}

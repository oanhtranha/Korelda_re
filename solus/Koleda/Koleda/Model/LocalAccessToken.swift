//
//  LocalAccessToken.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Locksmith

struct LocalAccessToken {
    
    static func store(_ token: String, tokenType: String) throws {
        // Deletion needed for the case when an access token with different accessible option is already present in the
        // keychain. In that case updating it fails with a duplication error.
        try? delete()
        try Locksmith.app_updateData(data: [accessTokenKey: token,
                                           tokenTypeKey: tokenType],
                                    forUserAccount: userAccountKey,
                                    inService: keychainService,
                                    accessibleOption: .alwaysThisDeviceOnly)
        log.info("Stored access token")
    }
    
    static func restore() -> String? {
        if let tokenInfo = Locksmith.loadDataForUserAccount(userAccount: userAccountKey, inService: keychainService) {
//            log.info("Retrieved access token info")
            return tokenInfo[accessTokenKey] as? String
        } else {
//            log.error("Can't retrieve access token")
            return nil
        }
    }
    
//    static func isExpired() -> Bool {
//        guard let tokenInfo = Locksmith.loadDataForUserAccount(userAccount: userAccountKey,
//                                                               inService: keychainService),
//            let timeIntervalSinceReferenceDate = tokenInfo[expirationDateKey] as? TimeInterval else
//        {
//            return false
//
//        }
//
//        let accessTokenExpirationDate = Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
//        let currentDate = Date()
//        return currentDate >= accessTokenExpirationDate
//    }
    
    static func isStored() -> Bool {
        return restore() != nil
    }
    
    static func delete() throws {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userAccountKey, inService: keychainService)
            log.info("Deleted access token")
        } catch LocksmithError.notFound {
            log.debug("Item to be deleted is not present in keychain")
        }
    }
    
    // MARK: - Implementation
    private static let accessTokenKey = "accessToken"
    private static let tokenTypeKey = "tokenType"
    private static let userAccountKey = "user.current.account"
    private static let keychainService = "com.koleda.accessToken"
}

extension Locksmith {
    
    static func  app_updateData(data: [String: Any],
                              forUserAccount userAccount: String,
                              inService service: String = LocksmithDefaultService,
                              accessibleOption: LocksmithAccessibleOption? = nil) throws
    {
        struct UpdateRequest: GenericPasswordSecureStorable, CreateableSecureStorable {
            let service: String
            let account: String
            let data: [String: Any]
            let accessible: LocksmithAccessibleOption?
        }
        
        let request = UpdateRequest(service: service,
                                    account: userAccount,
                                    data: data,
                                    accessible: accessibleOption)
        try request.updateInSecureStore()
    }
}

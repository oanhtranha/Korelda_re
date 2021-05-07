//
//  LocalizationManager.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 08/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

enum Strings {
    
    enum Raf: String {
        case rafDetails = "Raf_rafDetails"
        case rewardsTitle = "Raf_rewardsTitle"
        case companyDetails = "Raf_companyDetails"
        case getDiscount = "Raf_getDiscount"
        case getDiscountTitle = "Raf_getDiscountTitle"
        case getDiscountMessage = "Raf_getDiscountMessage"
        case cancel = "Raf_cancel"
        case getTheCode = "Raf_getTheCode"
        case refferYourFriends = "Raf_refferYourFriends"
        case shareNow = "Raf_shareNow"
        case retry = "Raf_retry"
        case noInternetConnection = "Raf_noInternetConnection"
        case discountCodesDescription = "Raf_discountCodesDescription"
        case noDiscountCodesDescription = "Raf_noDiscountCodesDescription"
        case generalError = "Raf_generalError"
        case noInternetConnectionAlert = "Raf_noInternetConnectionAlert"
        case generalErrorAlert = "Raf_generalErrorAlert"
    }
}

class LocalizationHelper {
    
    static func translatedStringForKey(key: String) -> String {
        
        let string = NSLocalizedString(key, bundle: Bundle.init(for: Copilot.self), comment: "")
        
        return string
    }
}


//
//  AppAlert.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

enum AppAlert {
    case discountCode(value: String?, storeName: String)
    case generalError
    case connectivityError
}

extension AppAlert: PopupRepresentable {
    
    var title: String? {
        var key: String?
        
        switch self {
        case .discountCode:
            key = Strings.Raf.getDiscountTitle.rawValue
        default:
            break
        }
        
        if let key = key {
            return LocalizationHelper.translatedStringForKey(key: key)
        }
        return nil
    }
    
    var message: String {
        switch self {
        case.discountCode(let value, let storeName):
            var finalValue = ""
            let alertMessage = LocalizationHelper.translatedStringForKey(key: Strings.Raf.getDiscountMessage.rawValue)
            if let value = value {
                finalValue = value
            }
            return String(format: alertMessage, finalValue, storeName)
        case .generalError:
            return LocalizationHelper.translatedStringForKey(key: Strings.Raf.generalErrorAlert.rawValue)
        case .connectivityError:
            return LocalizationHelper.translatedStringForKey(key: Strings.Raf.noInternetConnectionAlert.rawValue)
        }
    }
    
}

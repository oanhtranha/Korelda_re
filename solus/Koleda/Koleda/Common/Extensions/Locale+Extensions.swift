//
//  Locale+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation


extension Locale {
    // Provide valid ISO region code to obtain valid Locale
    static func fromCountryIsoCode(_ code: String) -> Locale {
        return Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code]))
    }
    
    static func currencyCode(forCountryIsoCode code: String) -> String? {
        guard let result = Locale.fromCountryIsoCode(code).currencyCode else {
            return nil
        }
        return result
    }
}

extension Locale {
    static var app_currentOrDefault: Locale {
        let defaultLocaleIdentifier = "en_US"
        let result: Locale
        if let prefferedLanguage = Locale.preferredLanguages.first,
            let languageCode = Locale.components(fromIdentifier: prefferedLanguage)[NSLocale.Key.languageCode.rawValue],
            Bundle.main.localizations.contains(languageCode) {
            result = Locale.current
        } else {
            result = Locale(identifier: defaultLocaleIdentifier)
        }
        
        return result
    }
    
    static var app_usPosixLocale: Locale {
        let usPosixLocaleIdentifier = "en_US_POSIX"
        return Locale(identifier: usPosixLocaleIdentifier)
    }
    
    static var bp_defaultLocale: Locale {
        let defaultLocaleIdentifier = "en_US_POSIX"
        return Locale(identifier: defaultLocaleIdentifier)
    }
}

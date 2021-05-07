//
//  DataValidator.swift
//  Koleda
//
//  Created by Oanh tran on 6/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

class DataValidator {
    
    class func isEmailValid(email: String?) -> Bool {
        return matches(string: email, pattern: "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")
    }
    
    class func isValid(fullName: String) -> Bool {
        return matches(string: fullName, pattern: "^[A-Za-z\\s]*$") &&
            fullName.components(separatedBy: .whitespaces).count > 1
    }
    
    class func isEmailPassword(pass: String?) -> Bool {
        return matches(string: pass, pattern: "^[a-zA-Z0-9'@&#-.\\s]{6,21}$")
    }
    
    class func isShellyDevice(hostName: String?) -> Bool {
        let hostNameUpperCase = hostName?.uppercased()
        return matches(string: hostNameUpperCase, pattern: "^(SHELLYHT)+-+[A-Z0-9]") || matches(string: hostNameUpperCase, pattern: "^(SOLUS-SENSOR)+-+[A-Z0-9]")
    }
    
    class func isShellyHeaterDevice(hostName: String?) -> Bool {
        let hostNameUpperCase = hostName?.uppercased()
        return matches(string: hostNameUpperCase, pattern: "^(SHELLY1PM)+-+[A-Z0-9]") || matches(string: hostNameUpperCase, pattern: "^(SOLUS-HEATER)+-+[A-Z0-9]")
    }
    
    private class func matches(string: String?, pattern: String) -> Bool {
        guard let string = string else { return false }
        
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            let range = string.startIndex..<string.endIndex
            
            return regularExpression.matches(in: string, options: [], range: string.nsRange(from: range)).count > 0
        } catch {
            return false
        }
    }
}

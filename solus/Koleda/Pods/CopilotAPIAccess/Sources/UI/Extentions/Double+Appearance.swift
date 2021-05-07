//
//  Double+Appearance.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 03/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

internal extension Double {
    
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    var smartPercision: String {
        return Int((self * 10).truncatingRemainder(dividingBy: 10)) == 0 ? ".0" : ".1"
    }
}

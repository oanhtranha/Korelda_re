//
//  ValueUnsetable.swift
//  CopilotAPIAccess
//
//  Created by Ofer Meroz on 12/11/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

protocol ValueUnsetable {
    mutating func unsetValue(forKey key: String)
}

extension Dictionary: ValueUnsetable where Key == String, Value == Any {
    
    mutating func unsetValue(forKey key: String) {
        self[key] = "$CopilotUnset$"
    }
}

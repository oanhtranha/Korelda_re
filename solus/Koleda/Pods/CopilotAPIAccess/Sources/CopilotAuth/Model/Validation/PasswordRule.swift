//
//  PasswordRule.swift
//  CopilotAuth
//
//  Created by Shachar Silbert on 28/08/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public protocol PasswordRule {
    
    var ruleId: PasswordRuleId {get}
    var numericalValue: Int {get}
    
    func isValid(password: String) -> Bool
}

//
//  PasswordRuleId.swift
//  CopilotAuth
//
//  Created by Shachar Silbert on 28/08/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

internal enum PasswordRuleDataType {
    case bool
    case int
}

public enum PasswordRuleId: String
{
    case minimumLength = "MinimumLength"
    case maximumLength = "MaximumLength"
    case maximumConsecutiveIdentical = "MaximumConsecutiveIdentical"
    case complexity_MinimumUpperCase = "Complexity_MinimumUpperCase"
    case complexity_MinimumLowerCase = "Complexity_MinimumLowerCase"
    case complexity_MinimumDigits = "Complexity_MinimumDigits"
    case complexity_MinimumSpecialChars = "Complexity_MinimumSpecialChars"
    case rejectWhiteSpace = "RejectWhiteSpace"
    
    internal var type: PasswordRuleDataType {
        switch self {
        
        case .minimumLength,
             .maximumLength,
             .maximumConsecutiveIdentical,
             .complexity_MinimumUpperCase,
             .complexity_MinimumLowerCase,
             .complexity_MinimumDigits,
             .complexity_MinimumSpecialChars:
            return .int
        case .rejectWhiteSpace:
            return .bool
        }
    }
}

//
//  PasswordRules.swift
//  CopilotAuth
//
//  Created by Shachar Silbert on 28/08/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

public struct PasswordRules {
    
    private struct Keys {
        static let rules = "rules"
    }
    
    internal static func parse(dictionary: [String: Any]) -> [PasswordRule] {
        
        guard let rulesUnparsed = dictionary[Keys.rules] as? [String: Any] else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Passsword rules reponse does not contain a '\(Keys.rules)' element")
            return []
        }
        
        var rules = [PasswordRule]()
        
        for (ruleIdString, value) in rulesUnparsed {
            if let rule = createRule(ruleIdString: ruleIdString, value: value) {
                rules.append(rule)
            }
        }
        
        return rules
    }
    
    private static func createRule(ruleIdString: String, value: Any) -> PasswordRule? {
        guard let ruleId = PasswordRuleId(rawValue: ruleIdString) else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Unable to find password rule id fitting rule of type \(ruleIdString)")
            return nil
        }
        
        guard let intValue = ( (ruleId.type == .int) ? (value as? Int) : -1 ) else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Value is not int for password rule of type \(ruleIdString) [\(value)]")
            return nil
        }
        
        switch ruleId {
        case .minimumLength:
            return MinimumLength(minimumLength: intValue)
        case .maximumLength:
            return MaximumLength(maximumLength: intValue)
        case .maximumConsecutiveIdentical:
            return MaximumConsecutiveIdentical(maxConsecutive: intValue)
        case .complexity_MinimumUpperCase:
            return Complexity_MinimumUpperCase(minCount: intValue)
        case .complexity_MinimumLowerCase:
            return Complexity_MinimumLowerCase(minCount: intValue)
        case .complexity_MinimumDigits:
            return Complexity_MinimumDigits(minCount: intValue)
        case .complexity_MinimumSpecialChars:
            return Complexity_MinimumSpecialChars(minCount: intValue)
        case .rejectWhiteSpace:
            return RejectWhiteSpace()
        }
    }
    
    public struct MinimumLength: PasswordRule {
        
        public let ruleId = PasswordRuleId.minimumLength
        public var numericalValue: Int { return minimumLength }
        
        let minimumLength: Int
        
        public func isValid(password: String) -> Bool {
            return password.count >= minimumLength
        }
        
    }
    
    public struct MaximumLength: PasswordRule {
        
        public let ruleId = PasswordRuleId.maximumLength
        public var numericalValue: Int { return maximumLength }
        
        let maximumLength: Int
        
        public func isValid(password: String) -> Bool {
            return password.count <= maximumLength
        }
        
    }
    
    public struct MaximumConsecutiveIdentical: PasswordRule {
        
        public let ruleId = PasswordRuleId.maximumConsecutiveIdentical
        public var numericalValue: Int { return maxConsecutive }
        
        private let regex: NSRegularExpression?
        private let maxConsecutive: Int
        
        init(maxConsecutive: Int) {
            self.maxConsecutive = maxConsecutive
            do {
                if maxConsecutive > 1 {
                    regex = try NSRegularExpression(pattern: "(.)\\1{\(maxConsecutive)}")
                }
                else {
                    regex = try NSRegularExpression(pattern: "(.)\\1")
                }
            }
            catch {
                ZLogManagerWrapper.sharedInstance.logError(message: "Regex could not be created for password rule [MaximumConsecutiveIdentical]: \(error)")
                regex = nil
            }
        }
        
        public func isValid(password: String) -> Bool {
            if let regex = regex {
                return regex.firstMatch(in: password, range: NSRange(location: 0, length: password.count)) == nil
            }
            return false
        }
        
    }
    
    public struct Complexity_MinimumUpperCase: PasswordRule {
        
        public let ruleId = PasswordRuleId.complexity_MinimumUpperCase
        public var numericalValue: Int { return minCount }
        
        private let regex: NSRegularExpression?

        let minCount: Int
        
        init(minCount: Int) {
            
            do {
                regex = try NSRegularExpression(pattern: "[A-Z]")
            }
            catch {
                ZLogManagerWrapper.sharedInstance.logError(message: "Regex could not be created for password rule [Complexity_MinimumUpperCase]: \(error)")
                regex = nil
            }
            
            self.minCount = minCount
        }
        
        public func isValid(password: String) -> Bool {
            if let regex = regex {
                return regex.matches(in: password, range: NSRange(location: 0, length: password.count)).count >= minCount
            }
            return false
        }
        
    }
    
    public struct Complexity_MinimumLowerCase: PasswordRule {
        
        public let ruleId = PasswordRuleId.complexity_MinimumLowerCase
        public var numericalValue: Int { return minCount }
        
        private let regex: NSRegularExpression?

        let minCount: Int
        
        init(minCount: Int) {
            
            do {
                regex = try NSRegularExpression(pattern: "[a-z]")
            }
            catch {
                ZLogManagerWrapper.sharedInstance.logError(message: "Regex could not be created for password rule [Complexity_MinimumLowerCase]: \(error)")
                regex = nil
            }
            
            self.minCount = minCount
        }
        
        public func isValid(password: String) -> Bool {
            if let regex = regex {
                return regex.matches(in: password, range: NSRange(location: 0, length: password.count)).count >= minCount
            }
            return false
        }
        
    }
    
    public struct Complexity_MinimumDigits: PasswordRule {
        
        public let ruleId = PasswordRuleId.complexity_MinimumDigits
        public var numericalValue: Int { return minCount }
        
        private let regex: NSRegularExpression?
        
        let minCount: Int
        
        init(minCount: Int) {
            
            do {
                regex = try NSRegularExpression(pattern: "[0-9]")
            }
            catch {
                ZLogManagerWrapper.sharedInstance.logError(message: "Regex could not be created for password rule [Complexity_MinimumDigits]: \(error)")
                regex = nil
            }
            
            self.minCount = minCount
        }
        
        public func isValid(password: String) -> Bool {
            if let regex = regex {
                return regex.matches(in: password, range: NSRange(location: 0, length: password.count)).count >= minCount
            }
            return false
        }
        
    }
    
    public struct Complexity_MinimumSpecialChars: PasswordRule {
        
        public let ruleId = PasswordRuleId.complexity_MinimumSpecialChars
        public var numericalValue: Int { return minCount }
        
        private let regex: NSRegularExpression?
        
        let minCount: Int
        
        init(minCount: Int) {
            
            do {
                regex = try NSRegularExpression(pattern: "[!\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]")
            }
            catch {
                ZLogManagerWrapper.sharedInstance.logError(message: "Regex could not be created for password rule [Complexity_MinimumSpecialChars]: \(error)")
                regex = nil
            }
            
            self.minCount = minCount
        }
        
        public func isValid(password: String) -> Bool {
            if let regex = regex {
                return regex.matches(in: password, range: NSRange(location: 0, length: password.count)).count >= minCount
            }
            return false
        }
    }
    
    
    public struct RejectWhiteSpace: PasswordRule {
        
        public let ruleId = PasswordRuleId.rejectWhiteSpace
        public var numericalValue: Int { return 1 }
        
        public func isValid(password: String) -> Bool {
            return password.rangeOfCharacter(from: .whitespacesAndNewlines) == nil
        }
    }
}

//
//  VerificationEmailResponse.swift
//  CopilotAPIAccess
//
//  Created by Adaya on 09/03/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class VerificationEmailResponse{
    public enum Constants {
        static let emailSentKey = "emailSent"
        static let retryAfterInSecondsKey = "retryAfterInSeconds"
    }
    
    public let emailSent: Bool
    public let retryAfterInSeconds: Int
    // MARK: - Init
    
    init?(withDictionary dictionary: [String: Any]) {
        guard let emailSentVal = dictionary[Constants.emailSentKey] as? Bool else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "Failed parsing verification email result - missing \(Constants.emailSentKey), or is in the wrong type")
            return nil
        }
        self.emailSent = emailSentVal
        
        if let retryAfterInSecondsVal = dictionary[Constants.retryAfterInSecondsKey] as? Int  {
            self.retryAfterInSeconds = retryAfterInSecondsVal
        }
        else{
            self.retryAfterInSeconds = 30// fallback to >0
        }
    }
    
}

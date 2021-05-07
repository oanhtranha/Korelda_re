//
//  InAppMessageConfiguration.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct InAppMessagesConfiguration {
    
    private enum TouchPolicyType: String {
        //The case value need to be exact name like we recieved from the server
        case timeBasedTouchPolicy = "TimeBased"
    }
    
    //MARK: - Consts
    private struct Keys {
        static let type = "_type"
        static let activated = "activated"
        static let pollingInterval = "pollingInterval"
        static let touchpointPolicy = "touchpointPolicy"
        static let authorizationType = "authorizationType"
    }
    
    //MARK: - Properties
    let activated: Bool
    let pollingInterval: Double
    let authorizationType: CopilotAuthType
    private(set) var touchPolicy: TouchPolicyValidator!
    
    // MARK: - Init
    init?(withDictionary dictionary: [String : Any]) {
        guard let activated = dictionary[Keys.activated] as? Bool,
            let pollingInterval = dictionary[Keys.pollingInterval] as? Double else { return nil }
        
        let touchpointPolicyDict = dictionary[Keys.touchpointPolicy] as? [String : Any]
        
        
        self.activated = activated
        self.pollingInterval = pollingInterval
        self.authorizationType = CopilotAuthType(rawValue: dictionary[Keys.authorizationType] as? String ?? "") ?? CopilotAuthType.Default
        self.touchPolicy = initTouchPolicyValidator(dictionary: touchpointPolicyDict)
    }
    
    //MARK: - Private
    private func initTouchPolicyValidator(dictionary: [String: Any]?) -> TouchPolicyValidator {
        let typeResponse = dictionary?[Keys.type] as? String
        switch typeResponse {
        case TouchPolicyType.timeBasedTouchPolicy.rawValue:
            if let dictionary = dictionary,let timeBasedTouchPolicy = TimeBasedTouchPolicyValidator(withDictionary: dictionary) {
                return timeBasedTouchPolicy
            }
        default:
            return DefaultTouchPolicyValidator()
        }
        return DefaultTouchPolicyValidator()
    }
}


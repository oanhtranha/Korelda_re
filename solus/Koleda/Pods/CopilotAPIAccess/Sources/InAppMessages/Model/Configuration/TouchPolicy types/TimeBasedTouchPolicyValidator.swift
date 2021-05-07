//
//  TimeBasedTouchPolicy.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class TimeBasedTouchPolicyValidator: TouchPolicyValidator {
    
    //MARK: - Consts
    private struct Keys {
        static let minSecondsBetweenInteractions = "minSecondsBetweenInteractions"
    }
    
    //MARK: - Properties
    private let minSecondsBetweenInteractions: TimeInterval
    
    private var previousInteractionInSeconds: TimeInterval = 0
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let minSecondsBetweenInteractions = dictionary[Keys.minSecondsBetweenInteractions] as? TimeInterval else { return nil }
    
        self.minSecondsBetweenInteractions = minSecondsBetweenInteractions
    }
    
    //MARK: - TouchPolicyValidator implementation
    func canInteractWithUser() -> Bool {
        return nowInSeconds() - previousInteractionInSeconds >= minSecondsBetweenInteractions
    }
    
    func setInteracted() {
        previousInteractionInSeconds = nowInSeconds()
    }
    
    //MARK: - Private
    private func nowInSeconds() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
}

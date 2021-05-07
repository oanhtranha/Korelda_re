//
//  TouchPolicyValidatorInactive.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class TouchPolicyValidatorInactive: TouchPolicyValidator {
    
    func canInteractWithUser() -> Bool { return false }
    func setInteracted() {}
}

//
//  DefaultTouchPolicyValidator.swift
//  CopilotAPIAccess
//
//  Created by Elad on 06/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class DefaultTouchPolicyValidator: TouchPolicyValidator {
    
    func canInteractWithUser() -> Bool { return true }
    
    func setInteracted() {
        //Do nothing
    }
}

//
//  TouchPolicyValidator.swift
//  CopilotAPIAccess
//
//  Created by Elad on 06/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol TouchPolicyValidator {
    func canInteractWithUser() -> Bool
    func setInteracted()
}


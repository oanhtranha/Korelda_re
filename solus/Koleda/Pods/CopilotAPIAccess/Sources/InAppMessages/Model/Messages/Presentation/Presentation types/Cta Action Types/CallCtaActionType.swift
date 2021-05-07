//
//  CallCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct CallCtaActionType: CtaAction {
    
    //MARK: - Consts
    private struct Keys {
        static let phoneNumber = "phoneNumber"
    }
    
    //MARK: - Properties
    let phoneNumber: String
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let phoneNumber = dictionary[Keys.phoneNumber] as? String else { return nil }
    
        self.phoneNumber = phoneNumber
    }
}

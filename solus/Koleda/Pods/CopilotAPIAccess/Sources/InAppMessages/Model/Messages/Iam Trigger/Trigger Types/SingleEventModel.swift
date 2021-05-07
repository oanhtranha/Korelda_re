//
//  SingleEventModel.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct SingleEventModel {
    
    //MARK: - Consts
    private struct Keys {
        static let name = "name"
    }
    
    //MARK: - Properties
    let name: String
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let name = dictionary[Keys.name] as? String else { return nil }
    
        self.name = name
    }
}

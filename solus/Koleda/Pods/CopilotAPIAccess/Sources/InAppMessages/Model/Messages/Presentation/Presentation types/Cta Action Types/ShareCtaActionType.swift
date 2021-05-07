//
//  ShareCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct ShareCtaActionType: CtaAction {
    
    //MARK: - Consts
    private struct Keys {
        static let text = "text"
    }
    
    //MARK: - Properties
    let text: String?
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        if let text = dictionary[Keys.text] as? String { self.text = text } else { self.text = nil }
    }
}

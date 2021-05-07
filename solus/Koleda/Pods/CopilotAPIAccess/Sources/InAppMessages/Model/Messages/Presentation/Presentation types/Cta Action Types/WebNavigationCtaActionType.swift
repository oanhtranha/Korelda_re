//
//  WebNavigationCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct WebNavigationCtaActionType: CtaAction {
    
    //MARK: - Consts
    private struct Keys {
        static let url = "url"
    }
    
    //MARK: - Properties
    let url: String
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let url = dictionary[Keys.url] as? String, url.isValidURL == true else { return nil }
        self.url = url
    }
}

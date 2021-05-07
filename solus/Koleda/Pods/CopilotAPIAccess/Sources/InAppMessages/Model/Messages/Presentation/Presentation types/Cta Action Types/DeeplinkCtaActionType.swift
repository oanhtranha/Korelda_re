//
//  DeepLinkCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 24/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct DeeplinkCtaActionType: CtaAction {
    
    //MARK: - Consts
    private struct Keys {
        static let deeplink = "deeplink"
    }
    
    //MARK: - Properties
    let deeplink: String
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let action = dictionary[Keys.deeplink] as? String else {
            return nil
        }
        self.deeplink = action
    }
}

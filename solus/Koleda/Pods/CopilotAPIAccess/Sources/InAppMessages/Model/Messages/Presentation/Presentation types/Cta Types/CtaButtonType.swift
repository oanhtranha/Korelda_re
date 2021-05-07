//
//  CtaButtonType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct CtaButtonType: CtaType {
    
    //MARK: - Consts
    private struct Keys {
        static let backgroundColorHex = "backgroundColorHex"
        static let text = "text"
        static let textColorHex = "textColorHex"
        static let action = "action"
        static let shouldDismiss = "shouldDismiss"
        static let report = "report"
    }
    
    //MARK: - Properties
    let backgroundColorHex: String
    let text: String
    let textColorHex: String
    let shouldDismiss: Bool?
    let action: CtaActionType
    let report: String?
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let text = dictionary[Keys.text] as? String,
            let actionDic = dictionary[Keys.action] as? [String : AnyObject],
            let action = CtaActionMapper.map(withDictionary: actionDic),
            let textColorHex = dictionary[Keys.textColorHex] as? String,
            let backgroundColorHex = dictionary[Keys.backgroundColorHex] as? String else { return nil }
        
        self.text = text
        self.action = action
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        
        if let shouldDismiss = dictionary[Keys.shouldDismiss] as? Bool { self.shouldDismiss = shouldDismiss } else { self.shouldDismiss = nil }
        if let report = dictionary[Keys.report] as? String { self.report = report } else { self.report = nil }
    }
}

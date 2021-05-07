//
//  CtaHtmlType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 29/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct CtaHtmlType: CtaType {
    
    //MARK: - Consts
    private struct Keys {
        static let redirectId = "redirectId"
        static let shouldDismiss = "shouldDismiss"
        static let action = "action"
        static let report = "report"
        
    }
    
    //MARK: - Propertiesee
    let redirectId: String
    let shouldDismiss: Bool?
    let action: CtaActionType
    let report: String?
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let redirectId = dictionary[Keys.redirectId] as? String,
            let actionDic = dictionary[Keys.action] as? [String : AnyObject],
            let action = CtaActionMapper.map(withDictionary: actionDic) else { return nil }
        
        self.redirectId = redirectId
        self.action = action
        
        if let shouldDismiss = dictionary[Keys.shouldDismiss] as? Bool { self.shouldDismiss = shouldDismiss } else { self.shouldDismiss = nil }
        if let report = dictionary[Keys.report] as? String { self.report = report } else { self.report = nil }
    }
}

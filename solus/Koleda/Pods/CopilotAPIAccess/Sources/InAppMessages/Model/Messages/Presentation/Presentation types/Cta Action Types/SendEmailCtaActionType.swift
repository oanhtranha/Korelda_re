//
//  SendEmailCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct SendEmailCtaActionType: CtaAction {
    //MARK: - Consts
    private struct Keys {
        static let mailto = "mailto"
        static let subject = "subject"
        static let body = "body"
    }
    
    //MARK: - Properties
    let mailTo: String?
    let subject: String?
    let body: String?
    
    // MARK: - Init
    init(withDictionary dictionary: [String: Any]) {
        if let mailTo = dictionary[Keys.mailto] as? String { self.mailTo = mailTo } else { self.mailTo = nil }
        if let subject = dictionary[Keys.subject] as? String { self.subject = subject } else { self.subject = nil }
        if let body = dictionary[Keys.body] as? String { self.body = body } else { self.body = nil }
    }
}

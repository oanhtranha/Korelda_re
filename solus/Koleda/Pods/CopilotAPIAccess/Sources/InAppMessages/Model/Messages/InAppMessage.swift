//
//  InappMessage.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppMessage {

    //MARK: - Consts
    private struct Keys {
        static let id = "id"
        static let report = "report"
        static let trigger = "trigger"
        static let presentation = "presentation"
    }
    
    //MARK: - Properties
    let id: String
    private(set) var report: InAppMessageReport = InAppMessageReport(parameters: [ : ])
    let trigger: InAppMessageTrigger
    let presentation: InAppMessagePresentation
    
    var status: InAppStatus
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let id = dictionary[Keys.id] as? String,
            let triggerDic = dictionary[Keys.trigger] as? [String : AnyObject],
            let trigger = MessageTriggerMapper.map(withDictionary: triggerDic),
            let presentationDic = dictionary[Keys.presentation] as? [String : AnyObject],
            let presentation = MessagePresentationMapper.map(withDictionary: presentationDic) else { return nil }
    
        self.id = id
        self.trigger = trigger
        self.presentation = presentation
        
        if let reportDic = dictionary[Keys.report] as? [String : String], reportDic.count > 0 {
            self.report = InAppMessageReport(parameters: reportDic)
        }
        
        status = trigger.getInitialState()
    }
    
    //Public
    func markAsEvicted() {
        status = .evicted
    }
}

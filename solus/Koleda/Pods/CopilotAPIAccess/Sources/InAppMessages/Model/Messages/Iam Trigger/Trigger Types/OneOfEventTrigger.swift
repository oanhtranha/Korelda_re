//
//  OneOfTrigger.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class OneOfEventTrigger: InAppMessageTrigger {
    
    //MARK: - Consts
    private struct Keys {
        static let events = "events"
    }
    
    //MARK: - Properties
    private let events: [SingleEventModel]
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        if let eventsResponse = dictionary[Keys.events] as? [[String : AnyObject]], eventsResponse.count > 0 {
            
            var eventsResponseJson: [SingleEventModel] = []
            eventsResponse.forEach {
                if let singleEventModel = SingleEventModel(withDictionary: $0) { eventsResponseJson.append(singleEventModel) }
            }
            self.events = eventsResponseJson
        } else { return nil }
    }
    
    //MARK: - InAppTrigger protocol
    func analyticsEventLogged(_ analyticsEvent: AnalyticsEvent) -> Bool {
        
        if let _ = events.first(where: { $0.name.caseInsensitiveCompare(analyticsEvent.eventName) == .orderedSame }) { return true }
        return false
    }
    
    func getInitialState() -> InAppStatus { return .pending }
}

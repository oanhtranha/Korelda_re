//
//  InAppInboxInactive.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppInboxInactive: InAppInboxInteractable {
    
    var messageTriggered: ((InAppMessage) -> ())? = nil
    
    var messages: [InAppMessage] = []
    
    func populateMessages(_ messages: [InAppMessage]) {}
    
    func readyToTrigger() {}
    
    func analyticsEventReceived(_ analyticsEvent: AnalyticsEvent) {}
    
    func resetInbox() {}
}

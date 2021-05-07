//
//  InAppInboxProtocol.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 23/12/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

protocol InAppInboxInteractable {
    var messageTriggered: ((InAppMessage) -> ())? { get set }
    var messages: [InAppMessage] { get }
    
    func populateMessages(_ messages: [InAppMessage])
    func readyToTrigger()
    func analyticsEventReceived(_ analyticsEvent: AnalyticsEvent)
    func resetInbox()
}




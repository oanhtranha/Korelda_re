//
//  InAppInbox.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 23/12/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class InAppInbox: InAppInboxInteractable {
    
    @AtomicWrite private(set) var messages =  [InAppMessage]()
            
    var messageTriggered: ((InAppMessage) -> ())?
    
    //MARK: - Public
    
    func populateMessages(_ newMessages: [InAppMessage]) {
        self._messages.mutate { (localMessages) in
            localMessages.forEach { (message) in
                newMessages.filter { $0.id == message.id }.last?.status = message.status
            }
            localMessages.removeAll()
            localMessages.insert(contentsOf: newMessages, at: 0)
        }
    }
    
    func readyToTrigger() {
        guard let isThereMessageToVerify = messages.first(where: { $0.status == .ready }) else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "Couldn't find message to trigger")
            return
        }
        dispatch(message: isThereMessageToVerify)
    }
    
    func analyticsEventReceived(_ analyticsEvent: AnalyticsEvent) {
        if let messageToVerify = messages.first(where: {
            
            $0.trigger.analyticsEventLogged(analyticsEvent) }) {
            messageToVerify.status = .ready
            dispatch(message: messageToVerify)
        }
    }
    
    func resetInbox() {
        self._messages.mutate { $0.removeAll() }
    }
    
    //MARK: - Private
    private func dispatch(message: InAppMessage) {
        self.messageTriggered?(message)
    }

}


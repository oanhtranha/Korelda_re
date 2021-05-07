//
//  AnalyticsEventsProvider.swift
//  AOTCore
//
//  Created by Tom Milberg on 08/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation
import CopilotLogger

class AnalyticsEventsProviderHandler: AnalyticsEventsProviderProtocol {
    
    var eventLogProviders = Array<EventLogProvider>()
    
    private let copilotConfigurationProvider: ConfigurationProvider
    
    init(copilotConfigurationProvider: ConfigurationProvider) {
        self.copilotConfigurationProvider = copilotConfigurationProvider
    }
    
    func addEventLogProvider(newEventLogProvider: EventLogProvider) {
        
        if copilotConfigurationProvider.manageType == .copilotConnect {
            if let isGDPRCompliant = copilotConfigurationProvider.isGdprCompliant {
                
                isGDPRCompliant ? newEventLogProvider.disable() : newEventLogProvider.enable()
                AnalyticsEventsManager.sharedInstance.shouldLogEvents = !isGDPRCompliant
            }
        }
        
        let eventLogProviderAlreadyExists = eventLogProviders.contains { (iteratedEventLogProvider) -> Bool in
            return iteratedEventLogProvider.providerName == newEventLogProvider.providerName
        }
        
        if (eventLogProviderAlreadyExists) {
            ZLogManagerWrapper.sharedInstance.logError(message: "Found duplicate event log provider: \(newEventLogProvider.providerName)")
        }
        else {
            eventLogProviders.append(newEventLogProvider)
        }
    }
    
    func removeEventLogProvider(eventLogProviderToRemove: EventLogProvider) {
        
        if let requiredIndex = eventLogProviders.firstIndex(where: { $0.providerName == eventLogProviderToRemove.providerName }) {
            eventLogProviders.remove(at: requiredIndex)
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Could not find the index for the event log provider that should get removed")
        }
    }
}

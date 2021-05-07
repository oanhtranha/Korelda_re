//
//  AnalyticsEventsManager.swift
//  AOTAuth
//
//  Created by Tom Milberg on 08/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

class AnalyticsEventsManager {

    static let sharedInstance = AnalyticsEventsManager()
    let eventsDispatcher: AnalyticsEventsDispatcher
    let sessionBasedAnalyticsRepository: SessionBasedAnalyticsRepository
    var shouldLogEvents: Bool = false
    
    var eventsProviderHandler: AnalyticsEventsProviderProtocol {
        return eventsDispatcher.eventsProviderHandler
    }

    private init() {
        let copilotConfigurationProvider = BundleConfigurationProvider()
        
        sessionBasedAnalyticsRepository = SessionBasedAnalyticsRepository()
        eventsDispatcher = AnalyticsEventsDispatcher(eventsProviderHandler: AnalyticsEventsProviderHandler(copilotConfigurationProvider: copilotConfigurationProvider), generalParametersRepository: sessionBasedAnalyticsRepository)
    }
    
    public func updateConsent(with actualConsent: Bool) {
        // update the providers according to the updated user consents
        eventsDispatcher.eventsProviderHandler.eventLogProviders.forEach { actualConsent ? $0.enable() : $0.disable() }
        shouldLogEvents = actualConsent
    }
}

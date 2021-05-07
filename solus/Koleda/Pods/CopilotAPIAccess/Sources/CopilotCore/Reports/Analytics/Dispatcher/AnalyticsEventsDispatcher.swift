//
//  AnalyticsEventsDispatcher.swift
//  AOTAuth
//
//  Created by Tom Milberg on 08/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation
import CopilotLogger

class AnalyticsEventsDispatcher {
    
    enum EventLogValidityStatus {
        case Ok
        case UnsupportedGroup
        case ProviderBlockedForReporting
    }
    
    let generalParametersRepository: SessionBasedAnalyticsRepository
    let eventsProviderHandler: AnalyticsEventsProviderHandler
    
    weak var eventsListener: AnalyticsEventReceiver?
    
    init(eventsProviderHandler: AnalyticsEventsProviderHandler, generalParametersRepository: SessionBasedAnalyticsRepository) {
        self.eventsProviderHandler = eventsProviderHandler
        self.generalParametersRepository = generalParametersRepository
    }
    
    //MARK: - Private
    
    fileprivate func internalLogAnalyticsEvent(event: AnalyticsEvent, logEventBlock: @escaping (_ eventLogProvider: EventLogProvider, _ eventName: String, _ eventTotalParams: Dictionary<String, String>) -> Void) {
        
        let eventParams = getAllEventParams(event: event)
        var didReportEvent = false
        
        for eventLogProvider: EventLogProvider in eventsProviderHandler.eventLogProviders {
            //Check if the event should be logged
            let eventLogValidityStatus = shouldLog(event: event, forEventLogProvider: eventLogProvider)
            
            switch eventLogValidityStatus {
            case .Ok:
                //Mark that the event was reported at least one time
                didReportEvent = true
                
                //Call the event log block
                let transformedEventParams = eventLogProvider.transformParameters(parameters: eventParams)
                logEventBlock(eventLogProvider, event.eventName, transformedEventParams)
            
            case .ProviderBlockedForReporting:
                ZLogManagerWrapper.sharedInstance.logInfo(message: "Event: \"\(event.eventName)\" won't get reported becuase provider: \"\(eventLogProvider.providerName)\" is blocked for reporting")
            case .UnsupportedGroup:
                ZLogManagerWrapper.sharedInstance.logInfo(message: "Event \"\(event.eventName)\" groups are unsupported for provider: \"\(eventLogProvider.providerName)\"")
            }
        }
        
        eventsListener?.eventLogged(event)
        
        //In case the event was not reported and there are providers, log it
        if !didReportEvent && eventsProviderHandler.eventLogProviders.count > 0 {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "Event \"\(event.eventName)\" was not reported to any provider")
        }
    }

    fileprivate func setProviderUserId(userId: String?){
        for eventLogProvider: EventLogProvider in eventsProviderHandler.eventLogProviders{
            eventLogProvider.setUserId(userId: userId)
        }
    }
    
    private func shouldLog(event: AnalyticsEvent, forEventLogProvider eventLogProvider: EventLogProvider) -> EventLogValidityStatus {
        
        let status: EventLogValidityStatus
        
        if AnalyticsEventsManager.sharedInstance.shouldLogEvents == false {
            status = .ProviderBlockedForReporting
        }
        else if eventLogProvider.providerEventGroups.hasAtLeastOneItemFromArray(secondArray: event.eventGroups) == false {
            status = .UnsupportedGroup
        }
        else {
            status = .Ok
        }
        
        return status
    }
    
    private func getAllEventParams(event: AnalyticsEvent) -> Dictionary<String, String> {
        
        let generalParams = getGeneralParams()
        var allParams = event.customParams
        
        //Add the event origin value
        allParams.updateValue(event.eventOrigin.rawValue, forKey: AnalyticsConstants.eventOriginKey)
        
        //Merging the custom params with the general params. Upon duplicate keys, the values from the custom params will stay and won't get replaced with the ones from the general params
        allParams.merge(generalParams) { (current, _) in current }
        
        return allParams
    }

    private func getGeneralParams() -> Dictionary<String, String> {
        var generalParams: [String: String] = [:]
        
        let sdkBundle = Bundle(for: type(of: self))
        let sdkVersion = sdkBundle.infoDictionary?[String.bundleShortVersionKey] as? String
        if let sdkVersion = sdkVersion {
            generalParams[String.copilotSDKVersionKey] = sdkVersion
        }

        //Collect all the general params from all repositories
        for generalParamsRepo: GeneralParametersRepository in generalParametersRepository.activeGeneralParamsRepoForSession {
            generalParamsRepo.generalParameters.forEach({ (k,v) in
                generalParams.updateValue(v, forKey: k)
            })
        }
        
        return generalParams
    }
}

//MARK: - AnalyticsDispatcher implementation

extension AnalyticsEventsDispatcher: AnalyticsDispatcher {

    func dispatcherLogCustomEvent(event: AnalyticsEvent) {
        
        DispatchQueue.global(qos: .utility).async {
            self.internalLogAnalyticsEvent(event: event) { (eventLogProvider, eventName, transformedParams) in
                eventLogProvider.logCustomEvent(eventName: eventName, transformedParams: transformedParams)
            }
        }
    }

    func setUserId(userId: String?){
        self.setProviderUserId(userId: userId)
    }
}

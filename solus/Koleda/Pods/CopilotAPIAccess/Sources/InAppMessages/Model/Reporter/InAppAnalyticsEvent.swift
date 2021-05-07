//
//  InAppAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Elad on 12/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol CopilotSystemEvent { }
class InAppAnalyticsEvent: AnalyticsEvent, CopilotSystemEvent {
    
    private struct Keys {
        static let EVENT_NAME_VALUE = "cplt_in_app"
        static let KEY_SUB_EVENT = "copilot_event_name"
        static let KEY_CTA = "cta"
    }
    
    var subEvent: InAppReporterSubEvent
    var generalParams: [String : String]
    
    //MARK: - Initializer
    init(subEvent: InAppReporterSubEvent, generalParams: [String : String]) {
        self.subEvent = subEvent
        self.generalParams = generalParams
    }
    
    //MARK: - Analytics events properties
    var customParams: Dictionary<String, String> {
        var paramsToReturn: [String : String] = [:]
        paramsToReturn[Keys.KEY_SUB_EVENT] = subEvent.reportValue
        paramsToReturn.merge(generalParams) { (_, last) in last }
        paramsToReturn[Keys.KEY_CTA] = subEvent.ctaReportParam
        return paramsToReturn
    }
    
    var eventName: String {
        return Keys.EVENT_NAME_VALUE
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

//
//  RafTapTermsAndConditionsAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapTermsAndConditionsAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_terms_and_conditions"
    private let termsLocationParamKey: String = "terms_location"
    
    private let termsLocation: TermsLocationType
    
    public enum TermsLocationType: String {
        case rewards
        case footer
    }
    
    public init(termsLocation: TermsLocationType) {
        self.termsLocation = termsLocation
    }
    
    public var customParams: Dictionary<String, String> {
        return [termsLocationParamKey : termsLocation.rawValue]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .User
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

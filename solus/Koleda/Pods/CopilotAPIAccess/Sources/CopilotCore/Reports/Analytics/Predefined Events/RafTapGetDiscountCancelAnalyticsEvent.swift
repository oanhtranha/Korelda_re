//
//  RafTapGetDiscountCancelAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapGetDiscountCancelAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_get_discount_code_cancel"
    
    public var customParams: Dictionary<String, String> {
        return Dictionary<String, String>()
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

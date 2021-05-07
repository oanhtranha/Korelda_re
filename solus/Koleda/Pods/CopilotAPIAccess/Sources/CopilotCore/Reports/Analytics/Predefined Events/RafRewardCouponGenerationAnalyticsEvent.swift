//
//  RafRewardCouponGenerationAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafRewardCouponGenerationAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_reward_coupon_generation"
    private let couponCodeGenerationSucceededParamKey: String = "coupon_code_generation_succeeded"
    
    private let couponCodeGenerationSucceeded: Bool
    
    public init(couponCodeGenerationSucceeded: Bool) {
        self.couponCodeGenerationSucceeded = couponCodeGenerationSucceeded
    }
    
    public var customParams: Dictionary<String, String> {
        return [couponCodeGenerationSucceededParamKey : String(couponCodeGenerationSucceeded)]
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

//
//  RafReferralCouponGenerationAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafReferralCouponGenerationAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_referral_coupon_generation"
    private let referralCodeGenerationSucceededParamKey: String = "referral_code_generation_succeeded"
    
    private let referralCodeGenerationSucceeded: Bool
    
    public init(referralCodeGenerationSucceeded: Bool) {
        self.referralCodeGenerationSucceeded = referralCodeGenerationSucceeded
    }
    
    public var customParams: Dictionary<String, String> {
        return [referralCodeGenerationSucceededParamKey : String(referralCodeGenerationSucceeded)]
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

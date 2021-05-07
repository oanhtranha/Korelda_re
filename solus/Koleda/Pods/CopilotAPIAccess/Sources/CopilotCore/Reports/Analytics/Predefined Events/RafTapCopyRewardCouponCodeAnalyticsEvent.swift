//
//  RafTapCopyRewardCouponCodeAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapCopyRewardCouponCodeAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_copy_reward_coupon_code"
    private let rewardCouponDiscountValueParamKey: String = "reward_coupon_discount_value"
    private let rewardCouponDiscountCurrencyCodeParamKey: String = "reward_coupon_discount_currency_code"
    
    private let rewardCouponDiscountValue: Double
    private let rewardCouponDiscountCurrencyCode: String
    
    public init(rewardCouponDiscountValue: Double, rewardCouponDiscountCurrencyCode: String) {
        self.rewardCouponDiscountValue = rewardCouponDiscountValue
        self.rewardCouponDiscountCurrencyCode = rewardCouponDiscountCurrencyCode
    }
    
    public var customParams: Dictionary<String, String> {
        return [rewardCouponDiscountValueParamKey : String(rewardCouponDiscountValue), rewardCouponDiscountCurrencyCodeParamKey : rewardCouponDiscountCurrencyCode]
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

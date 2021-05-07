//
//  RafTapGetDiscountAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapGetDiscountAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_get_discount"
    private let rewardAggregatedValueParamKey: String = "reward_aggregated_value"
    private let rewardAggregatedCurrencyCodeParamKey: String = "reward_aggregated_currency_code"
    
    private let rewardAggregatedValue: Double?
    private let rewardAggregatedCurrencyCode: String?
    
    public init(rewardAggregatedValue: Double?, rewardAggregatedCurrencyCode: String?) {
        self.rewardAggregatedValue = rewardAggregatedValue
        self.rewardAggregatedCurrencyCode = rewardAggregatedCurrencyCode
    }
    
    public var customParams: Dictionary<String, String> {
        var params = Dictionary<String, String>()
        
        if let rewardAggregatedValue = rewardAggregatedValue {
            params[rewardAggregatedValueParamKey] = String(rewardAggregatedValue)
        } else {
            params[rewardAggregatedValueParamKey] = "-1"
        }
        
        if let rewardAggregatedCurrencyCode = rewardAggregatedCurrencyCode {
            params[rewardAggregatedCurrencyCodeParamKey] = rewardAggregatedCurrencyCode
        }
        
        return params
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

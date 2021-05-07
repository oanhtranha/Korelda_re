//
//  RafTapRewardCreditAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapRewardCreditAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_reward_credit"
    private let screenName = "refer_a_friend"
    private let rewardValueParamKey = "reward_value"
    private let rewardIsSelectedParamKey = "reward_is_selected"
    private let rewardCurrencyCodeParamKey = "reward_currency_code"
    private let rewardSumAvailableParamKey = "reward_sum_available"
    
    private let rewardValue: Double
    private let rewardIsSelected: Bool
    private let rewardCurrencyCode: String
    private let rewardSumAvailable: Double?
    
    public init(rewardValue: Double, rewardIsSelected: Bool, rewardCurrencyCode: String, rewardSumAvailable: Double?) {
        self.rewardValue = rewardValue
        self.rewardIsSelected = rewardIsSelected
        self.rewardCurrencyCode = rewardCurrencyCode
        self.rewardSumAvailable = rewardSumAvailable
    }
    
    public var customParams: Dictionary<String, String> {
        var params = [AnalyticsConstants.screenNameKey : screenName, rewardValueParamKey : String(rewardValue), rewardIsSelectedParamKey : String(rewardIsSelected), rewardCurrencyCodeParamKey : rewardCurrencyCode]
        
        if let rewardSumAvailable = rewardSumAvailable {
            params[rewardSumAvailableParamKey] = String(rewardSumAvailable)
        } else {
            params[rewardSumAvailableParamKey] = "-1"
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

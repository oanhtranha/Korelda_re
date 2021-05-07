//
//  RafTapShareReferralCouponAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapShareReferralCouponAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_share_referral_coupon"
    private let programTypeParamKey: String = "program_type"
    
    private let programType: ProgramType
    
    public enum ProgramType: String {
        case altruistic = "altruistic"
        case activeProgram = "active_program"
    }
    
    public init(programType: ProgramType) {
        self.programType = programType
    }
    
    public var customParams: Dictionary<String, String> {
        return [programTypeParamKey : programType.rawValue]
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

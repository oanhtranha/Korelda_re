//
//  RafScreenLoadAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public class RafScreenLoadAnalyticsEvent: ScreenLoadAnalyticsEvent {

    private let screenName = "refer_a_friend"
    private let programTypeParamKey = "program_type"
    private let hasBalanceParamKey = "has_balance"
    
    public enum ProgramType: String {
        case altruistic = "altruistic"
        case activeProgram = "active_program"
    }
    
    private let programType: ProgramType
    private let hasBalance: Bool
    
    public init(programType: ProgramType, hasBalance: Bool) {
        self.programType = programType
        self.hasBalance = hasBalance
        
        super.init(screenName: screenName)
    }
    
    override public var customParams: Dictionary<String, String> {
        var params = super.customParams
        params[programTypeParamKey] = programType.rawValue
        params[hasBalanceParamKey] = String(hasBalance)
        return params
    }
    
}

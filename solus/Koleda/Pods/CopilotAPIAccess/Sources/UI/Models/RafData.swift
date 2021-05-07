//
//  RafData.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 26/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafData {
    let staticData: StaticData
    let rafProgram: RafProgram?
    let altruisticProgram: AltruisticProgram
    let rewards: [Reward]
    let discountCodes: [DiscountCode]
    let dynamicData: DynamicData?
    let pendingJobs: [RafJob]
    
    var isAltruisticProgram: Bool {
        return rafProgram == nil
    }
    
    var hasBalance: Bool {
        let hasRewards = !rewards.isEmpty && rewards.count != 0
        let hasDiscountCodes = !discountCodes.isEmpty && discountCodes.count != 0
        return hasRewards || hasDiscountCodes
    }
}

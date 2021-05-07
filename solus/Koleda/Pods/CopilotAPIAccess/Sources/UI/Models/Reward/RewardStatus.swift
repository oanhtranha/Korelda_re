//
//  RewardStatus.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 14/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

enum RewardStatus: String, Comparable, CaseIterable {
    case active = "activeReward"
    case pending = "disableReward"
    case returned = "returnedReward"
    case dummy = "rewardPlaceholder"
    case claimed = "claimedReward"
    
    var image: UIImage? {
        return UIImage(named: rawValue, in: Bundle(for: Copilot.self), compatibleWith: nil)
    }
    
    var rewardTypeString: String {
        switch self {
        case .returned:
            return "Returned"
        case .claimed:
            return "Claimed"
        default:
            return ""
        }
    }
    
    private var sortOrder: Int {
        switch self {
        case .active:
            return 0
        case .pending:
            return 1
        case .returned:
            return 2
        case .claimed:
            return 3
        case .dummy:
            return 4
        }
    }
    
    static func ==(lhs: RewardStatus, rhs: RewardStatus) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
    
    static func <(lhs: RewardStatus, rhs: RewardStatus) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}

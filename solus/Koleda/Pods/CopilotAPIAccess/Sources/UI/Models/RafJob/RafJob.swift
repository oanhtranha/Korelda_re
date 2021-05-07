//
//  RafJob.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 01/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafJob {
    let id: String
    let status: RafJobStatus
    let type: RafJobType
    let retryAfter: Int?
}

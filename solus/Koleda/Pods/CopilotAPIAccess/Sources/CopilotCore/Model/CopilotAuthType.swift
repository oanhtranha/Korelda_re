//
//  CopilotAuthType.swift
//  ZemingoBLELayer
//
//  Created by Shachar Silbert on 01/09/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import Moya

enum CopilotAuthType: String {
    case bearer = "Bearer"
    case basic = "Basic"
    
    static let Default = CopilotAuthType.bearer
    
    func toMoyaAuthorizationType() -> AuthorizationType {
        switch self {
        case .bearer:
            return .bearer
        case .basic:
            return .basic
        }
    }
}

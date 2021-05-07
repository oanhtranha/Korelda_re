//
//  ExternalUserGeneralParametersRepository.swift
//  ZemingoBLELayer
//
//  Created by Revital Pisman on 08/05/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class ExternalUserGeneralParametersRepository: UserGeneralParametersRepository {
    
    var userId: String? = nil
    
    var additionalParams: [String : String] {
        return [:]
    }

    var additionalParamsKeys: [String] {
        return []
    }
}


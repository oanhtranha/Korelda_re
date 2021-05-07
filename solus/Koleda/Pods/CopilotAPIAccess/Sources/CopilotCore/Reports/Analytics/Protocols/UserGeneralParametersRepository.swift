//
//  UserGeneralParametersRepository.swift
//  ZemingoBLELayer
//
//  Created by Revital Pisman on 12/05/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public protocol UserGeneralParametersRepository: GeneralParametersRepository {
    var userId: String? { get }
    var userIDParamKey: String { get }
    var additionalParams: [String : String] { get }
    var additionalParamsKeys: [String] { get }
}

extension UserGeneralParametersRepository {
    var userIDParamKey: String {
        return "user_id"
    }
    
    var generalParameters: [String : String] {
        // build the dict
        var params = [String : String]()
        params[userIDParamKey] = userId
        params.merge(additionalParams) { (current, _) -> String in
            return current
        }
        return params
    }
    
    var generalParametersKeys: [String] {
        // build the array
        var paramsKeys = [userIDParamKey]
        paramsKeys.append(contentsOf: additionalParams.keys)
        return paramsKeys
    }
}

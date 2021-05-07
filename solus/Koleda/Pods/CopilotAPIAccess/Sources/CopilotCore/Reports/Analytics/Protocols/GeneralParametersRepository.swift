//
//  File.swift
//  AOTCore
//
//  Created by Tom Milberg on 09/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol GeneralParametersRepository: class {
    var generalParameters:[String : String] { get }
    var generalParametersKeys: [String] { get }
}

extension GeneralParametersRepository {
    
    func areGeneralParametersTheSame(rhs: GeneralParametersRepository) -> Bool {
        var areEqual = true
        
        let lhsGeneralParamsKeys = self.generalParametersKeys
        let rhsGeneralParamsKeys = rhs.generalParametersKeys
        
        //Check that the number of elements is the same
        if lhsGeneralParamsKeys.count == rhsGeneralParamsKeys.count {
            
            //For every key in lhs, check that it exists in rhs
            for lhsGeneralParamKey in lhsGeneralParamsKeys {
                if rhsGeneralParamsKeys.contains(lhsGeneralParamKey) == false {
                    areEqual = false
                    break
                }
            }
        }
        else {
            areEqual = false
        }
        
        return areEqual
    }
    
}

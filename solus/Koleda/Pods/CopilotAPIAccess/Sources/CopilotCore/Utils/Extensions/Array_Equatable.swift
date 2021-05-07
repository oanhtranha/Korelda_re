//
//  Array.swift
//  AotGateway
//
//  Created by Tom Milberg on 28/05/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    func hasAtLeastOneItemFromArray(secondArray: Array) -> Bool {
        var hasAtLeastOneItemFromSecondArray = false
        
        for item in secondArray {
            hasAtLeastOneItemFromSecondArray = contains(item)
            if hasAtLeastOneItemFromSecondArray {
                break
            }
        }
        
        return hasAtLeastOneItemFromSecondArray
    }
}


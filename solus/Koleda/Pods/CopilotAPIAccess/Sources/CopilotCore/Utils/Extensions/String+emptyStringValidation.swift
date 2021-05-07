//
//  String+emptyStringValidation.swift
//  ZemingoBLELayer
//
//  Created by Revital Pisman on 15/07/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

internal extension String {
    
    func isTrimmedEmpty() -> Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
}

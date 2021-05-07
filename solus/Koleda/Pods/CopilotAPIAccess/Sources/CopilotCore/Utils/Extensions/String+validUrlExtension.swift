//
//  String+validUrlExtension.swift
//  CopilotAPIAccess
//
//  Created by Elad on 09/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

extension String {
    var isValidURL: Bool {
        let urlRegEx = "^(https?|http)://[^\\s/$.?#].[^\\s]*"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
}


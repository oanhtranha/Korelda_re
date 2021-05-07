//
//  String+Base64.swift
//  CopilotAPIAccess
//
//  Created by Elad on 15/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

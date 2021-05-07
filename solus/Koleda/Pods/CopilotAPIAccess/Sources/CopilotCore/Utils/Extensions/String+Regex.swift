//
//  String+Regex.swift
//  CopilotAPIAccess
//
//  Created by Elad on 18/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger
extension String {
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            ZLogManagerWrapper.sharedInstance.logError(message: "invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

//
//  String+deletePrefixAndSuffix.swift
//  CopilotAPIAccess
//
//  Created by Elad on 18/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

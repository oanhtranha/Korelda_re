//
//  CopilotError.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 24/07/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

protocol CopilotError: Error {
    static func generalError(message: String) -> Self
}

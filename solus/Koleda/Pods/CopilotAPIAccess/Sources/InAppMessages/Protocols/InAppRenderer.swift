//
//  InAppRenderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol InAppRenderer {
    func render(inAppMessage: InAppMessage, reporter: InAppReporter, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ())
}

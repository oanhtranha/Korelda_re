//
//  InAppRenderingManagerInactive.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppRenderingManagerInactive: InAppRenderer {
    func render(inAppMessage: InAppMessage, reporter: InAppReporter, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ()) {}
}

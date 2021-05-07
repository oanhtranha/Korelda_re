//
//  InAppRenderingManager.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppRenderingManager: InAppRenderer {
    func render(inAppMessage: InAppMessage, reporter: InAppReporter, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            inAppMessage.presentation.renderer.render(reporter: reporter, iamReport: inAppMessage.report, delegate: delegate, completion: completion)
        }
    }

}




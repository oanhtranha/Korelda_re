//
//  InAppFetcherManagerInactive.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppFetcherManagerInactive: InAppFetcher {
    func start(pollingInterval: TimeInterval) {}
    func start() {}
    func stop() {}
    var pollingInterval: TimeInterval = 0
    var messagesArrived: (([InAppMessage]) -> ())? = nil
}

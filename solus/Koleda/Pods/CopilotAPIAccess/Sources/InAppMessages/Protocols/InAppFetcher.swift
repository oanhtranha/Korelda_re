//
//  InAppFetcher.swift
//  CopilotAPIAccess
//
//  Created by Elad on 05/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol InAppFetcher {
    func start()
    func stop()
    var pollingInterval: TimeInterval { get set }
    var messagesArrived: (([InAppMessage]) -> ())? { get set }
}

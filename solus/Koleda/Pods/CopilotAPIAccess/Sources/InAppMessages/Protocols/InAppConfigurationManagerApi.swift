//
//  InAppConfigurationManagerApi.swift
//  CopilotAPIAccess
//
//  Created by Elad on 03/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol InAppConfigurationManagerApi {
    func start()
    func clear()
    var configutationRecieved: ((InAppMessagesConfiguration) -> ())? { get set }
}

//
//  InAppServiceInteractionClosures.swift
//  CopilotAPIAccess
//
//  Created by Elad on 22/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

typealias FetchInAppMessagesClosure = (Response<InAppMessages, GetInAppMessagesError>) -> Void
typealias FetchInAppMessageDisplayedClosure = (Response<InAppMessageStatus, MessageDisplayedError>) -> Void
typealias FetchInAppConfigurationClosure = (Response<InAppMessagesConfiguration, GetInAppConfigurationError>) -> Void

struct InAppMessageStatus { }


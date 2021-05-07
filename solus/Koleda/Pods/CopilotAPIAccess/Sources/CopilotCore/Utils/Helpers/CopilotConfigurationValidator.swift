//
//  CopilotConfigurationValidator.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 29/10/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

internal struct CopilotConfigurationValidator {
    
    let copilotBundleConfigurationProvider: ConfigurationProvider
    
    init(copilotBundleConfigurationProvider: ConfigurationProvider) {
        self.copilotBundleConfigurationProvider = copilotBundleConfigurationProvider
    }
    
    func validate() {
        if copilotBundleConfigurationProvider.manageType == .yourOwn {
            // S2S Topology 2
            
            if copilotBundleConfigurationProvider.baseUrl == nil {
                ZLogManagerWrapper.sharedInstance.logError(message: "Copilot-Info.plist file is missing the `ENVIRONMENT_URL` key, it should point to a String value.")
            }
            
            // Configuration verified
            return
        }
        
        // S2S Topology 1
        if copilotBundleConfigurationProvider.isGdprCompliant != nil {
            if copilotBundleConfigurationProvider.applicationId != nil {
                if copilotBundleConfigurationProvider.baseUrl != nil {
                    
                    // Configuration verified
                    return
                } else {
                    fatalError("Copilot-Info.plist file is missing the mandatory `ENVIRONMENT_URL` key, it should point to a String value.")
                }
            } else {
                fatalError("Copilot-Info.plist file is missing the mandatory `APPLICATION_ID` key, it should point to a String value.")
            }
        } else {
            fatalError("Copilot-Info.plist file is missing the mandatory `IS_GDPR_COMPLIANT` key, it should point to a Bool value.")
        }
    }
}

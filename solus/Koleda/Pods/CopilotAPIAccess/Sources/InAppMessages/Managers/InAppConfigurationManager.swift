//
//  InAppConfigurationManager.swift
//  CopilotAPIAccess
//
//  Created by Elad on 30/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger


class InAppConfigurationManager {
    
    private struct Consts {
        #if DEBUG
        static let CONFIGURATION_MINIMUM_GAP_IN_SECONDS: Double = 10 * 60
        #else
        static let CONFIGURATION_MINIMUM_GAP_IN_SECONDS: Double = 60 * 60
        #endif
    }
    
    //MARK: - Properties
    
    typealias Dependencies = HasInAppServiceInteraction
    private var dependencies: Dependencies
    
    private var lastTimeConfigFetched: TimeInterval = 0
    private var isInAppMessageActivated: Bool = false
            
    var configutationRecieved: ((InAppMessagesConfiguration) -> ())?
    
    //MARK: - Initializer
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    //MARK: - Private
    private func fetchConfiguration() {
        dependencies.inAppServiceInteraction.getInAppConfiguration {[weak self] (response) in
            switch response {
            case .success(let configuration):
                self?.lastTimeConfigFetched = Date().timeIntervalSince1970
                self?.isInAppMessageActivated = configuration.activated
                
                self?.configutationRecieved?(configuration)
                
            case .failure(let error):
                self?.isInAppMessageActivated = false
                self?.lastTimeConfigFetched = Date().timeIntervalSinceNow
                ZLogManagerWrapper.sharedInstance.logError(message: "getInAppConfiguration failied because of error: \(error)")
            }
        }
    }
}

extension InAppConfigurationManager: InAppConfigurationManagerApi {
    
    //FIXME: call start when needed
    func start() {
        let now = Date().timeIntervalSince1970
        if now - lastTimeConfigFetched >= Consts.CONFIGURATION_MINIMUM_GAP_IN_SECONDS {
            fetchConfiguration()
        }  else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "No need to fetch config, age is less than minimum threshold")
        }
    }
    
    func clear() {
        lastTimeConfigFetched = 0
        isInAppMessageActivated = false
    }
}






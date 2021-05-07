//
//  InAppFetcherManager.swift
//  CopilotAPIAccess
//
//  Created by Elad on 05/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger



class InAppFetcherManager: InAppFetcher {
    
        
    private struct Consts {
        static let POLLING_INTERVAL_DEFAULT_VALUE: Double = 60
    }

    //MARK: - Properties
    
    typealias Dependencies = HasInAppServiceInteraction
    private var dependencies: Dependencies
    
    var pollingInterval: TimeInterval = Consts.POLLING_INTERVAL_DEFAULT_VALUE//FIXME: change this to the real deafult value
    private var isPolling = false
            
    private var timer: Timer?
        
    var messagesArrived: (([InAppMessage]) -> ())?
    
    //MARK: - Initializer
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func start() {
        if !isPolling {
            isPolling = true
            startPolling()
        } else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "fetcher is alrady polling")
        }
    }
    func stop() {
        isPolling = false
        timer?.invalidate()
        timer = nil
    }

    //MARK: - Private
    
    private func startPolling() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "Start to poll")
        
        guard timer == nil else { return }
        
        getMessagesRequest()

        DispatchQueue.main.async { [weak self] in
            guard let pollingInterval = self?.pollingInterval else { return }
            self?.timer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true, block: { (_) in
                self?.getMessagesRequest()
            })
        }
    }
    
    private func getMessagesRequest() {
        dependencies.inAppServiceInteraction.getInAppMessages {[weak self](response) in
            switch response {
            case .success(let iamMessages):
                self?.messagesArrived?(iamMessages.messages)
            case .failure(let error):
                ZLogManagerWrapper.sharedInstance.logError(message: "get messages failed because of error: \(error.localizedDescription)")
            }
        }
    }
}



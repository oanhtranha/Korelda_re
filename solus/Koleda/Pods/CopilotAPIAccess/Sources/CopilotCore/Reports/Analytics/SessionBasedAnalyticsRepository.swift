//
//  SessionBasedAnalyticsRepository.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation
import CopilotLogger

class SessionBasedAnalyticsRepository {
    
    private(set) var activeGeneralParamsRepoForSession = Array<GeneralParametersRepository>()
    private let lock = NSLock()
    
    func addGeneralParamsForCurrentSession(generalParamsForSession: GeneralParametersRepository) {
        lock.lock()
        
        let newGeneralParamsRepoKeys = generalParamsForSession.generalParametersKeys
        
        let generalParametersAlreadyExists = activeGeneralParamsRepoForSession.contains { (iteratedGeneralParametersRepository) -> Bool in
            return iteratedGeneralParametersRepository.generalParametersKeys.hasAtLeastOneItemFromArray(secondArray: newGeneralParamsRepoKeys)
        }
        
        if !generalParametersAlreadyExists {
            activeGeneralParamsRepoForSession.append(generalParamsForSession)
        }
        else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "Found at least one duplicated general parameter, trying to replace the previous one")
            
            var indexOfDuplicateRepository: Int?
            
            for (index, repository) in activeGeneralParamsRepoForSession.enumerated() {
                if repository.areGeneralParametersTheSame(rhs: generalParamsForSession) {
                    indexOfDuplicateRepository = index
                    break
                }
            }
            
            if let duplicateRepositoryIndex = indexOfDuplicateRepository {
                if duplicateRepositoryIndex <  activeGeneralParamsRepoForSession.count {
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "Found duplicate general parameters, replacing it by \(newGeneralParamsRepoKeys)")
                    activeGeneralParamsRepoForSession.remove(at: duplicateRepositoryIndex)
                    activeGeneralParamsRepoForSession.append(generalParamsForSession)
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "Replaced with success general params repo for session, adding it to activeGeneralParamsRepoForSession")
                } else {
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "While attempting to remove duplicate repository but index of duplicate is out of bounds index.")
                }
            } else {
                //In the AnalyticsEventsDispatcher the last repo overrides the same keys in other repositories when event logged.
                ZLogManagerWrapper.sharedInstance.logInfo(message: "New repo added, the new repo include same keys as existing repo with new keys")
                activeGeneralParamsRepoForSession.append(generalParamsForSession)
            }
        }
        
        lock.unlock()
    }
    
    func sessionEnded() {
        lock.lock()
        
        activeGeneralParamsRepoForSession.forEach { (generalParamRepo) in
            
            if let requiredIndex = activeGeneralParamsRepoForSession.firstIndex(where: { $0.areGeneralParametersTheSame(rhs: generalParamRepo)}) {
                activeGeneralParamsRepoForSession.remove(at: requiredIndex)
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "Could not find the index for the general parameters that should get removed")
            }
        }
        activeGeneralParamsRepoForSession.removeAll()
        
        lock.unlock()
    }
    
}

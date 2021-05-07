//
//  InAppServiceInteraction.swift
//  CopilotAPIAccess
//
//  Created by Elad on 23/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

protocol InAppServiceInteractable {
    func getInAppMessages(getInAppMessagesClosure: @escaping FetchInAppMessagesClosure)
    func postMessageDisplayed(messageId: String, inAppMessageDisplayedClosure: @escaping FetchInAppMessageDisplayedClosure)
    func getInAppConfiguration(inAppConfigurationClosure: @escaping FetchInAppConfigurationClosure)
}

internal class InAppServiceInteraction {
    
    fileprivate var requestExecutor: RequestExecutor<InAppService>
    fileprivate var authenticatedRequestExecutor: AuthenticatedRequestExecutor<InAppService>?
    private let configurationProvider: ConfigurationProvider
    private var authenticationProvider: AuthenticationProvider?
    private var authType: CopilotAuthType?
    
    // MARK: - Init
    init(configurationProvider: ConfigurationProvider, sequentialExecutionHelper: MoyaSequentialExecutionHelper) {
        self.configurationProvider = configurationProvider
        requestExecutor = RequestExecutor(sequentialExecutionHelper: sequentialExecutionHelper)
    }
    
    func setAuthProvider(_ authenticationProvider: AuthenticationProvider) {
        self.authenticationProvider = authenticationProvider
    }
    
    func setAuthType(authType: CopilotAuthType, userId: String?) {
        
        self.authType = authType
        
        switch authType {
        case .basic:
            authenticatedRequestExecutor = AuthenticatedRequestExecutor<InAppService>(authenticationProvider: CopilotBasicAuthenticationProvider(userId), sequentialExecutionHelper: requestExecutor.sequentialExecutionHelper)
        case .bearer:
            if let authenticationProvider = authenticationProvider {
                authenticatedRequestExecutor = AuthenticatedRequestExecutor<InAppService>(authenticationProvider: authenticationProvider, sequentialExecutionHelper: requestExecutor.sequentialExecutionHelper)
            }
        }
    }
}

//MARK: - InAppServiceInteractable
extension InAppServiceInteraction: InAppServiceInteractable {

    func postMessageDisplayed(messageId: String, inAppMessageDisplayedClosure: @escaping FetchInAppMessageDisplayedClosure) {
        let postMessageDisplayed = InAppService.postMessageDisplayed(messageId: messageId, authType: authType?.toMoyaAuthorizationType())
        
        authenticatedRequestExecutor?.executeRequest(target: postMessageDisplayed) { [weak self] (requestExecuterResponse) in
            if let weakSelf = self {
                weakSelf.handlePostInAppMessageDisplayedExecuterResult(requestExecuterResponse, postInAppMessageDisplayedClosure: inAppMessageDisplayedClosure)
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "cannot handle postInappMessageDisplayed response because self is nil")
            }
        }
    }
    
    func getInAppMessages(getInAppMessagesClosure getInAppDataClosure: @escaping FetchInAppMessagesClosure) {
        let getInAppMessagesService = InAppService.getInAppMessages(authType: authType?.toMoyaAuthorizationType())

        authenticatedRequestExecutor?.executeRequest(target: getInAppMessagesService) { [weak self] (requestExecuterResponse) in
            if let weakSelf = self {
                weakSelf.handleGetInAppMessagesExecuterResult(requestExecuterResponse, getInAppMessagesClosure: getInAppDataClosure)
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "cannot handle getInappData response because self is nil")
            }
        }
    }
    
    func getInAppConfiguration(inAppConfigurationClosure: @escaping FetchInAppConfigurationClosure) {
        
        let iOS = "IOS"
        let sdkVersion = Bundle(for: type(of: self)).infoDictionary?[String.bundleShortVersionKey] as? String ?? "Unknown"
        
        let getInAppConfigService = InAppService.getInAppConfiguration(os: iOS, appVersion: configurationProvider.appVersion, sdkVerion: sdkVersion)

        requestExecutor.executeRequest(target: getInAppConfigService) { [weak self] (requestExecuterResponse) in
            if let weakSelf = self {
                weakSelf.handleGetInAppConfigExecuterResult(requestExecuterResponse, inAppConfigClosure: inAppConfigurationClosure)
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "cannot handle getConfig response because self is nil")
            }
        }
    }
    
    
    //MARK: - Private helper methods
    
    private func handleGetInAppMessagesExecuterResult(_ response: RequestExecutorResponse, getInAppMessagesClosure: FetchInAppMessagesClosure) {

        var getInAppMessagesResponse: Response<InAppMessages, GetInAppMessagesError>
        
        switch response {
        case .failure(error: let serverError):
            getInAppMessagesResponse = .failure(error: FetchInAppMessagesErrorResolver().resolve(serverError))
            
        case .success(payload: let dictionary):
            if let inAppMessagesResponse = InAppMessages(withDictionary: dictionary) {
                getInAppMessagesResponse = .success(inAppMessagesResponse)
            }
            else {
                getInAppMessagesResponse = .failure(error: .generalError(debugMessage: "Failed to create messages from dictionary"))
            }
        }
        getInAppMessagesClosure(getInAppMessagesResponse)
    }
    
    private func handlePostInAppMessageDisplayedExecuterResult(_ response: RequestExecutorResponse, postInAppMessageDisplayedClosure: FetchInAppMessageDisplayedClosure) {
       
        var postInAppMessageDisplayedResponse: Response<InAppMessageStatus, MessageDisplayedError>
        
        switch response {
        case .failure(error: let serverError):
            postInAppMessageDisplayedResponse = .failure(error: FetchMessageDisplayedErrorResolver().resolve(serverError))
            
        case .success( _ ):
            postInAppMessageDisplayedResponse = .success(InAppMessageStatus())
        }
        postInAppMessageDisplayedClosure(postInAppMessageDisplayedResponse)
    }
    
    private func handleGetInAppConfigExecuterResult(_ response: RequestExecutorResponse, inAppConfigClosure: FetchInAppConfigurationClosure) {
       
        var getInAppConfigurationResponse: Response<InAppMessagesConfiguration, GetInAppConfigurationError>
        
        switch response {
        case .failure(error: let serverError):
            getInAppConfigurationResponse = .failure(error: FetchInAppConfigurationErrorResolver().resolve(serverError))
            
        case .success(payload: let dictionary):
            if let iamConfigurationResponse = InAppMessagesConfiguration(withDictionary: dictionary) {
                getInAppConfigurationResponse = .success(iamConfigurationResponse)
            }
            else {
                getInAppConfigurationResponse = .failure(error: .generalError(debugMessage: "Failed to create configuration from dictionary"))
            }
        }
        inAppConfigClosure(getInAppConfigurationResponse)
    }
}


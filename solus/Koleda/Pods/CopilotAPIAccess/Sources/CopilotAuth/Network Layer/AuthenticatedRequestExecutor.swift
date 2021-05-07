//
//  AuthenticatedRequestExecutor.swift
//  GreenRide-Inu
//
//  Created by Miko Halevi on 7/31/17.
//  Copyright © 2017 Miko Halevi. All rights reserved.
//

import Foundation
import Moya
import CopilotLogger

class AuthenticatedRequestExecutor<T: TargetType>: RequestExecutor<T> {
    
    private let authenticationProvider: AuthenticationProvider
    
    init(authenticationProvider: AuthenticationProvider, sequentialExecutionHelper: MoyaSequentialExecutionHelper) {
        self.authenticationProvider = authenticationProvider
        super.init(sequentialExecutionHelper: sequentialExecutionHelper)
    }
    
    //MARK: Inheritance
    
    internal override func createMoyaProvider() -> MoyaProvider<T>  {

        return MoyaProvider<T>(session: sequentialExecutionHelper.session, plugins: createMoyaPlugins())
    }
    
    override func createMoyaPlugins() -> [PluginType] {
        var plugins = super.createMoyaPlugins()
        if let token = authenticationProvider.accessToken {
            let authPlugin = AccessTokenPlugin { _ in token }
            plugins.append(authPlugin)
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "trying to execute securedRequest Without access token")
        }
        return plugins
    }
    
    override internal func handleCompletion(_ completion: @escaping RequestExecutorWithHeadersClosure, target:T, shouldRetry: Bool, response: RequestExecutorWithHeadersResponse) {
        if !shouldRetry {
            completion(response)
        }
        else {
            switch response {
            case .success(payload: _):
                completion(response)
            case .failure(error: let error):
                atttemptToRecoverUnauthorized(completion, target: target, originalError: error)
            }
        }
    }

    private func atttemptToRecoverUnauthorized(_ completion: @escaping RequestExecutorWithHeadersClosure, target: T, originalError: ServerError) {
        switch originalError {
        case .authorizationFailure:
            if authenticationProvider.canLoginSilently {
                authenticationProvider.refreshToken(WithClosure: { (refreshTokenResponse) in
                    switch refreshTokenResponse {
                    case .success:
                        self.executeRequestWithHeaders(target: target, shouldRetry: false, completion: completion)
                    case .failure(error: let providerError):
                        switch providerError{
                        case .requiresRelogin:
                            completion(.failure(error: .authorizationFailure))
                        case .generalError(let debugMessage):
                            completion(.failure(error: .generalError(message: "Failed during attempt to refresh the token: \(debugMessage)")))
                        case .connectivityError(let debugMessage):
                            let e = InternalError(message: "Failed during attempt to refresh the token: \(debugMessage)")
                            completion(.failure(error: .communication(error: e)))
                        }
                    }
                })
            } else {
                completion(.failure(error: originalError))
            }
        default:
            completion(.failure(error: originalError))
        }
    }
    
    private func handleCompletionWithGrace(_ isGrace: Bool, completion: @escaping RequestExecutorClosure, target:T, response: RequestExecutorResponse) {
        
    }
}

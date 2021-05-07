//
//  AuthenticationServiceInteraction.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

protocol AuthenticationServiceInteractable {
    func register(withEmail email:String, password: String, firstName: String, lastName: String, consents:[String: Bool], registerClosure: @escaping RegisterClosure)
    func registerAnonymously(withConsents consents:[String: Bool], registerClosure: @escaping RegisterAnonymouslyClosure)
    func elevateAnonymous(withEmail email:String, password: String, firstName: String, lastName: String, elevateClosure: @escaping ElevateAnonymousClosure)
    func login(withEmail email:String, password: String, loginClosure: @escaping LoginClosure)
    func requireResetPassword(withEmail email:String,  closure: @escaping RequireResetPasswordClosure)
    func getPasswordRulesPolicy(closure: @escaping GetPasswordRulesPolicyClosure)
    func approveTermsOfUse(for termsOfUseVersion: String, closure: @escaping ApproveTermsOfUseClosure)
    func setConsents(details consentsDetails: [String: Bool], closure: @escaping SetConsetClosure)
    func changePassword(newPassword: String, oldPassword: String, closure: @escaping ChangePasswordClosure)
    func consentRefused(closure: @escaping ConsetRefusedClosure)
    func sendVerificationEmail(closure: @escaping SendVerificationEmailClosure)
    func logout(logoutClosure: LogoutClosure)
    func attemptToSilentLogin(closure: @escaping SilentLoginClosure)
}

class AuthenticationServiceInteraction: AuthenticationProvider {
    
    private let sessionLifeTimeProvider: SessionLifeTimeProvider
    
    fileprivate var token: Token?
    
    var isLoggedIn: Bool {
        get {
            return token != nil ? true : false
        }
    }
    
    fileprivate var requestExecutor: RequestExecutor<AuthenticationService>
    fileprivate var authenticatedExecuter : AuthenticatedRequestExecutor<AuthenticationService>!
    
    //MARK: Init
    
    init(sessionObserver: SessionLifeTimeObserver, sequentialExecutionHelper: MoyaSequentialExecutionHelper) {
        requestExecutor = RequestExecutor(sequentialExecutionHelper: sequentialExecutionHelper)
        sessionLifeTimeProvider = SessionLifeTimeProvider()
        sessionLifeTimeProvider.add(observer: sessionObserver)
        authenticatedExecuter = AuthenticatedRequestExecutor(authenticationProvider: self, sequentialExecutionHelper: sequentialExecutionHelper)
    }
    
    //MARK: Private

    fileprivate func handleRegisterExecutorResult(_ response: RequestExecutorResponse, authenticationClosure: RegisterClosure  ) {
        var registerarionResponse: Response<Void, SignupError>
        
        switch response {
        case .failure(error: let serverError):
            registerarionResponse = .failure(error: SignupErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                registerarionResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
                registerarionResponse = .success(())
            }
        }
        
        authenticationClosure(registerarionResponse)
    }
    
    fileprivate func handleRegisterAnonymouslyExecutorResult(_ response: RequestExecutorResponse, authenticationClosure: RegisterAnonymouslyClosure) {
        var registerResponse: Response<Void,  SignupAnonymouslyError>
        switch response {
        case .failure(error: let serverError):
            registerResponse = .failure(error: SignupAnonymousErrorResolver().resolve(serverError))
        case .success(let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                registerResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
                registerResponse = .success(())
            }
        }
        authenticationClosure(registerResponse)
    }
    
    fileprivate func handleElevateAnonymousExecutorResult(_ response: RequestExecutorResponse, elevateClosure: ElevateAnonymousClosure) {
        var elevateResponse: Response<Void, ElevateAnonymousUserError>
        switch response {
        case .failure(error: let serverError):
            self.handleFailureInTokenResponse(serverError)
            elevateResponse = .failure(error: ElevateAnonymousErrorResolver().resolve(serverError))
        case .success(let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                elevateResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
                elevateResponse = .success(())
            }
        }
        elevateClosure(elevateResponse)
    }
    
    fileprivate func handleRequestResetExecutorResult(_ response: RequestExecutorResponse, closure: RequireResetPasswordClosure) {
        var requireResponse: Response<Void, ResetPasswordError>
        switch response {
        case .failure(error: let serverError):
            requireResponse = .failure(error: ResetPasswordErrorResolver().resolve(serverError))
        case .success(payload: _):
            requireResponse = .success(())
        }
        closure(requireResponse)
    }
    
    fileprivate func handleGetPasswordRulesPolicyResponse(_ response: RequestExecutorResponse, closure: GetPasswordRulesPolicyClosure) {
        var requireResponse: Response<[PasswordRule], FetchPasswordRulesPolicyError>
        switch response {
        case .failure(error: let serverError):
             requireResponse = .failure(error: FetchPasswordRulesPolicyErrorResolver().resolve(serverError))
        case .success(let payload):
            //Parse the rules from the payload
            requireResponse = .success(PasswordRules.parse(dictionary: payload))
        }
        
        closure(requireResponse)
    }
    
    fileprivate func handleApproveResponse(_ response: RequestExecutorResponse, closure: ApproveTermsOfUseClosure) {
        var requireResponse: Response<Void, ApproveTermsOfUseError>
        switch response {
        case .failure(error: let serverError):
            self.handleFailureInTokenResponse(serverError)
            requireResponse = .failure(error: ApproveTermsOfUseErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                requireResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                requireResponse = .success(())
            }
        }
        closure(requireResponse)
    }

    fileprivate func handleChangePasswordResponse(_ response: RequestExecutorResponse, closure: ChangePasswordClosure) {
        var requireResponse: Response<Void, ChangePasswordError>
        switch response {
        case .failure(error: let serverError):
            self.handleFailureInTokenResponse(serverError)
            requireResponse = .failure(error: ChangePasswordErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                requireResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                requireResponse = .success(())
            }
        }
        closure(requireResponse)
    }
    
    fileprivate func handleSendVerificationEmailResponse(_ response: RequestExecutorResponse, closure: SendVerificationEmailClosure) {
        var requireResponse: Response<Void, SendVerificationEmailError>
        switch response {
        case .failure(error: let serverError):
            requireResponse = .failure(error: SendVerificationEmailErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let sendVerificationResponse = VerificationEmailResponse(withDictionary: dictionary) {
                if sendVerificationResponse.emailSent{
                    requireResponse = .success(())
                }
                else{
                    requireResponse = .failure(error: .retryRequired(retryInSeconds: sendVerificationResponse.retryAfterInSeconds, debugMessage: "The server did not send the email, you should retry within \(sendVerificationResponse.retryAfterInSeconds) seconds"))
                }
            }
            else {
                requireResponse = .failure(error: .generalError(debugMessage: "Failed parsing response \(dictionary)"))
            }
        }
        closure(requireResponse)
    }

    fileprivate func handleConsentResponse(_ response: RequestExecutorResponse, closure: SetConsetClosure) {
        var consentResponse: Response<Void, UpdateUserConsentError>

        switch response {
        case .failure(error: let serverError):
            self.handleFailureInTokenResponse(serverError)
            consentResponse = .failure(error: UpdateUserConsentErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                consentResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                consentResponse = .success(())
            }
        }
        
        closure(consentResponse)
    }
    
    fileprivate func handleConsentRefusedResponse(_ response: RequestExecutorResponse, closure: ConsetRefusedClosure) {
        
        switch response {
        case .failure(error: let serverError):
            closure(.failure(error: ConsentRefusedErrorResolver().resolve(serverError)))
        case .success(payload: _):
            closure(.success(()))
        }
    }
    
    fileprivate func handleLoginExecutorResult(_ response: RequestExecutorResponse, authenticationClosure: LoginClosure  ) {
        var loginResponse: Response<Void, LoginError>

        switch response {
        case .failure(error: let serverError):
            loginResponse = .failure(error: LoginErrorResolver().resolve(serverError))
        case .success(payload: let dictionary):
            if let parsingError = self.handleSuccessfulTokenResponse(dictionary) {
                loginResponse = .failure(error: .generalError(debugMessage: parsingError.localizedDescription))
            }
            else {
                sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
                loginResponse = .success(())
            }
        }
        
        authenticationClosure(loginResponse)
    }
    
    fileprivate func handleSuccessfulTokenResponse(_ responseAsDictionary: [String : Any]) -> Swift.Error? {
        if let authentication = AuthenticationCredentials(withDictionary: responseAsDictionary) {
            if let persistancyError = TokenPersistancyManager.sharedInstance.saveToken(authentication.refreshToken) {
                ZLogManagerWrapper.sharedInstance.logError(message: "TokenPersistancyManager failed to save token")
                return persistancyError
            }
            else {
                ZLogManagerWrapper.sharedInstance.logInfo(message: "Stored new token")
                self.token = authentication.accessToken                
                return nil          //no error -> success
            }
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Failed to create AuthenticationCredentials from response")
            return InternalError(message: "Failed to create AuthenticationCredentials from response")
        }
    }
    
    fileprivate func handleFailureInTokenResponse(_ serverError: ServerError){
        switch serverError {
        case .authorizationFailure:
            _ = logoutLocal()
            return
        case .copilotError(let statusCode, let reason,_):
            if(ServerError.isMarkedForDeletionError(statusCode, reason)){
                _ = logoutLocal()
                return
            }
            fallthrough
        case .validationError:
            fallthrough
        case .internalServerError:
            fallthrough
        case .unknown:
            fallthrough
        case .communication:
            fallthrough
        case .generalError:
            return
        }
    }

    //MARK: AuthenticationProvider
    
    var accessToken: Token? {
        get {
            return token
        }
    }
    
    var canLoginSilently: Bool {
        let result = TokenPersistancyManager.sharedInstance.getToken()
        
        switch result {
        case .success(let refreshToken):
            return refreshToken != nil
        case .failure(_):
            return true
        }
    }
    
    func refreshToken(WithClosure closure: @escaping RefreshTokenClosure) {
        let result = TokenPersistancyManager.sharedInstance.getToken()
        
        switch result {
        case .success(let refreshToken):
            if let refreshToken = refreshToken {
                let refreshTokenService: AuthenticationService = .refresh(token: refreshToken)
                requestExecutor.executeRequest(target: refreshTokenService, completion: { (executeRequestResult) in
                    switch executeRequestResult {
                    case .failure(error: let serverError):
                        self.handleFailureInTokenResponse(serverError)
                        closure(.failure(error: RefreshTokenErrorResolver().resolve(serverError)))
                    case .success(payload: let dictionary):
                        if let authentication = AuthenticationCredentials(withDictionary: dictionary) {
                            if let persistancyError = TokenPersistancyManager.sharedInstance.saveToken(authentication.refreshToken) {
                                ZLogManagerWrapper.sharedInstance.logError(message: "Failed saveToken with error: \(persistancyError.localizedDescription)")
                                closure(.failure(error: .generalError(debugMessage: persistancyError.localizedDescription)))
                            }
                            else {
                                self.token = authentication.accessToken
                                closure(.success(()))
                            }
                        }
                        else {
                            closure(.failure(error: .generalError(debugMessage: "Parsing AuthenticationCredentials to dictionary failed")))
                        }
                    }
                })
            }
            else {
                closure(.failure(error: RefreshTokenError.requiresRelogin(debugMessage: "Could not fetch refresh token from persistency")))
            }
            
        case .failure(let error):
            switch error {
            case .generalError:
                closure(.failure(error: .generalError(debugMessage: "Could not fetch refresh token from persistency")))
            }
        }
    }
}


extension AuthenticationServiceInteraction: AuthenticationServiceInteractable {
    func sendVerificationEmail(closure: @escaping SendVerificationEmailClosure) {
        let sendVerification : AuthenticationService = .sendVerificationEmail
        authenticatedExecuter.executeRequest(target: sendVerification) { [weak self](response) in
            self?.handleSendVerificationEmailResponse(response, closure: closure)
        }
    }

    func changePassword(newPassword: String, oldPassword: String, closure: @escaping ChangePasswordClosure) {
        let changePassword : AuthenticationService = .changePassword(newPassword: newPassword, oldPassword: oldPassword)
        authenticatedExecuter.executeRequest(target: changePassword) { [weak self](response) in
            self?.handleChangePasswordResponse(response, closure: closure)
        }
    }


    func register(withEmail email:String, password: String, firstName: String, lastName: String, consents:[String: Bool], registerClosure: @escaping RegisterClosure) {
        
        let deviceDetails = AnalyticsParameterProvider.kAnalyticsParametersDeviceDetails
        let registerService: AuthenticationService = .register(email: email, password: password, firstName: firstName, lastName: lastName, consents: consents, deviceDetails: deviceDetails)
        
        requestExecutor.executeRequest(target: registerService) { [weak self] (result) in
            self?.handleRegisterExecutorResult(result, authenticationClosure: registerClosure)
        }
    }
    
    func registerAnonymously(withConsents consents:[String: Bool], registerClosure: @escaping RegisterAnonymouslyClosure) {
        let deviceDetails = AnalyticsParameterProvider.kAnalyticsParametersDeviceDetails
        let registerAnonymously: AuthenticationService = .registerAnonymously(consents: consents, deviceDetails: deviceDetails)
        
        requestExecutor.executeRequest(target: registerAnonymously) { [weak self] (result) in
            self?.handleRegisterAnonymouslyExecutorResult(result, authenticationClosure: registerClosure)
        }
    }
    
    func elevateAnonymous(withEmail email:String, password: String, firstName: String, lastName: String, elevateClosure: @escaping ElevateAnonymousClosure) {
        let elevateAnonymousService: AuthenticationService = .elevateAnonymous(email: email, password: password, firstName: firstName, lastName: lastName)
        
        authenticatedExecuter.executeRequest(target: elevateAnonymousService) { [weak self] (result) in
            self?.handleElevateAnonymousExecutorResult(result, elevateClosure: elevateClosure)
        }
    }
    
    func login(withEmail email:String, password: String, loginClosure: @escaping LoginClosure) {
        let deviceDetails = AnalyticsParameterProvider.kAnalyticsParametersDeviceDetails
        let loginService: AuthenticationService = .login(email: email, password: password, deviceDetails: deviceDetails)
        
        requestExecutor.executeRequest(target: loginService) { [weak self] (result) in
            self?.handleLoginExecutorResult(result, authenticationClosure: loginClosure)
        }
    }
    
    func requireResetPassword(withEmail email:String,  closure: @escaping RequireResetPasswordClosure) {
        let resetService : AuthenticationService = .requireResetPassword(email: email)
        requestExecutor.executeRequest(target: resetService) { [weak self] (result) in
            self?.handleRequestResetExecutorResult(result, closure: closure)
        }
    }
    
    func getPasswordRulesPolicy(closure: @escaping GetPasswordRulesPolicyClosure) {
        let passwordService: AuthenticationService = .getPasswordPolicy(userRole: "AppUser")
        requestExecutor.executeRequest(target: passwordService) { [weak self] (result) in
            self?.handleGetPasswordRulesPolicyResponse(result, closure: closure)
        }
    }
    
    func approveTermsOfUse(for termsOfUseVersion: String, closure: @escaping ApproveTermsOfUseClosure) {
        let approve : AuthenticationService = .approveTermsAndConditions(termsOfUseVersion: termsOfUseVersion)
        authenticatedExecuter.executeRequest(target: approve) { [weak self](response) in
            self?.handleApproveResponse(response, closure: closure)
        }
    }
    
    func setConsents(details consentsDetails: [String: Bool], closure: @escaping SetConsetClosure) {
        let consent : AuthenticationService = .consent(consentsDetails: consentsDetails)
        authenticatedExecuter.executeRequest(target: consent) { [weak self](response) in
            self?.handleConsentResponse(response, closure: closure)
        }
    }
    
    func consentRefused(closure: @escaping ConsetRefusedClosure) {
        let consentRefused : AuthenticationService = .consetRefused
        authenticatedExecuter.executeRequest(target: consentRefused) { [weak self](response) in
            self?.handleConsentRefusedResponse(response, closure: closure)
        }
    }
    
    func logout(logoutClosure: LogoutClosure) {
        
        if let error = logoutLocal(){
            logoutClosure(.failure(error: error))
        }
        else{
            logoutClosure(.success(()))
        }
    }

    func logoutLocal() -> LogoutError?{
        //Notify the analytics component
        AnalyticsEventsManager.sharedInstance.sessionBasedAnalyticsRepository.sessionEnded()
        AnalyticsEventsManager.sharedInstance.eventsDispatcher.setUserId(userId: nil)
        self.token = nil
        //notify session ended
        sessionLifeTimeProvider.invoke { $0?.sessionEnded() }
        // we start with local logout
        if let error = TokenPersistancyManager.sharedInstance.deleteToken(){
            ZLogManagerWrapper.sharedInstance.logError(message: "error deleting refresh token with error: \(error.localizedDescription)")
            let loError = LogoutError.internalError(InternalError(message: error.localizedDescription))
            self.token = nil
            return loError
        }
        else{
            return nil
        }
    }
    
    func attemptToSilentLogin(closure: @escaping SilentLoginClosure) {
        if !canLoginSilently{
            closure(.failure(error: .requiresRelogin(debugMessage: "Please verify that canLoginSilently returns true")))
        }
        else if accessToken != nil{
            sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
            closure(.success(()))
        }
        else{
            refreshToken(WithClosure: { (response) in
                switch response{
                case .failure(error: let refreshError):
                    let silentLoginError = refreshError
                    closure(.failure(error: silentLoginError))
                case .success:
                    self.sessionLifeTimeProvider.invoke { $0?.sessionStarted() }
                    closure(.success(()))
                }
            })
        }
    }
}

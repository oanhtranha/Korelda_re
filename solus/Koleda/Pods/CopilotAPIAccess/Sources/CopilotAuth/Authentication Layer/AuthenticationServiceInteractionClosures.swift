//
//  AuthenticationServiceInteractionClosures.swift
//  CopilotAPIAccess
//
//  Created by Richard Houta on 11/10/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

typealias RegisterClosure =  (Response<Void, SignupError>) -> Void
typealias RegisterAnonymouslyClosure = (Response<Void, SignupAnonymouslyError>) -> Void
typealias ElevateAnonymousClosure = (Response<Void, ElevateAnonymousUserError>) -> Void
typealias LoginClosure =  (Response<Void, LoginError>) -> Void
typealias LogoutClosure = (Response<Void, LogoutError>) -> Void
typealias SilentLoginClosure = (Response<Void, LoginSilentlyError>) -> Void
typealias RequireResetPasswordClosure  = (Response<Void, ResetPasswordError>) -> Void
typealias GetPasswordRulesPolicyClosure = (Response<[PasswordRule], FetchPasswordRulesPolicyError>) -> Void
typealias ApproveTermsOfUseClosure  = (Response<Void, ApproveTermsOfUseError>) -> Void
typealias SetConsetClosure = (Response<Void, UpdateUserConsentError>) -> Void
typealias SendVerificationEmailClosure = (Response<Void, SendVerificationEmailError>) -> Void
typealias ChangePasswordClosure = (Response<Void, ChangePasswordError>) -> Void
typealias ConsetRefusedClosure = (Response<Void, ConsentRefusedError>) -> Void

//
//  AuthenticationProvider.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public typealias RefreshTokenClosure = (Response<Void, RefreshTokenError>) -> Void

public typealias Token = String

public protocol AuthenticationProvider {
    var isLoggedIn: Bool { get }
    var accessToken: Token? { get }
    var canLoginSilently: Bool { get }
    func refreshToken(WithClosure closure: @escaping RefreshTokenClosure)
}

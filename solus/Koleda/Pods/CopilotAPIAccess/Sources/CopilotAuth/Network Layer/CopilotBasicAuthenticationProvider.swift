//
//  CopilotBasicAuthenticationProvider.swift
//  CopilotAPIAccess
//
//  Created by Shachar Silbert on 02/09/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

struct CopilotBasicAuthenticationProvider: AuthenticationProvider {
    
    var isLoggedIn: Bool = true
    var canLoginSilently: Bool = true
    
    var accessToken: Token?
    
    init(_ userId: String?, _ password: String? = nil) {
        if let userId = userId {
            accessToken = "\(userId):\(password ?? "")".toBase64()
        }
    }
    
    func refreshToken(WithClosure closure: @escaping RefreshTokenClosure) {}
    
}

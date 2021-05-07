//
//  TokenPersistancyProtocol.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

protocol TokenPersistancyProtocol {
    func saveToken(_ token: Token) -> Error?
    func getToken() -> Response<String?, PersistancyError>
    func deleteToken() -> Error?
}

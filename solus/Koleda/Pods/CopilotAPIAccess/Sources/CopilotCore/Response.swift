//
//  Response.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 24/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum Response<T, E: Error> {
    case success(T)
    case failure(error: E)
}

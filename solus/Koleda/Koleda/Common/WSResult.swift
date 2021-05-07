//
//  WSResult.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

public enum WSResult<T> {
    case success(T)
    case failure(Error)
    
    public init(value: T) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
}

extension WSResult where T == Void {
    static var success: WSResult {
        return .success(())
    }
}

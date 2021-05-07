//
//  MoyaAsyncOperation.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/04/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import Moya

class MoyaAsyncOperation<T: TargetType>: AsynchronousOperation {
    
    //MARK: - Properties
    private let provider: MoyaProvider<T>
    private let target: T
    private let completion: Completion?
    
    //MARK: - Initializer
    init(provider: MoyaProvider<T>, target: T, completion: Completion?) {
        self.provider = provider
        self.target = target
        self.completion = completion
    }
    
    //MARK: - Override
    override func main() {
        provider.request(target, callbackQueue: DispatchQueue.global(qos: .userInteractive)) { [weak self] (moyaResult) in
            self?.completion?(moyaResult)
            self?.completeOperation()
        }
    }
}

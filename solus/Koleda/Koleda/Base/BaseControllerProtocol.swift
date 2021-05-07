//
//  BaseControllerProtocol.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

protocol BaseControllerProtocol: class {
    
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
}


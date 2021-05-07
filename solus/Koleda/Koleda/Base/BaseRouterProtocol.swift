//
//  BaseRouterProtocol.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

protocol BaseRouterProtocol {
    
    var baseViewController: UIViewController? { get set }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?)
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?)
    
    func prepare(for segue: UIStoryboardSegue)
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?)
}

extension BaseRouterProtocol {
    
    func present(on baseVC: UIViewController) {
        self.present(on: baseVC, animated: true, context: nil, completion: nil)
    }

    func enqueueRoute(with context: Any?) {
        self.enqueueRoute(with: context, animated: true, completion: nil)
    }
    
    func enqueueRoute(with context: Any?, completion: ((Bool) -> Void)?) {
        self.enqueueRoute(with: context, animated: true, completion: completion)
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        self.prepare(for: segue)
    }
    
}


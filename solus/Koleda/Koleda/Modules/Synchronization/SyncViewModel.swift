//
//  SyncViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SyncViewModelProtocol: BaseViewModelProtocol {
    var profileImage: Driver<UIImage?> { get }
    func showTermAndConditionScreen()
}

class SyncViewModel: SyncViewModelProtocol {
    
    var router: BaseRouterProtocol
    
    var profileImage: Driver<UIImage?> { return profileImageSubject.asDriver(onErrorJustReturn: nil) }
    
    private var profileImageSubject = BehaviorSubject<UIImage?>(value: UIImage(named: "defaultProfileImage"))
    
    init(with router: BaseRouterProtocol) {
        self.router = router
    }
    
    func showTermAndConditionScreen() {
        router.enqueueRoute(with: SyncRouter.RouteType.termAndCondition)
    }
    
}

//
//  GuideViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol GuideViewModelProtocol: BaseViewModelProtocol {
    var guideItems: Variable<[GuideItem]>  { get }
    func next()
    func viewWillAppear()
}
class GuideViewModel: GuideViewModelProtocol {
    
    let guideItems = Variable<[GuideItem]>([])
    private let isGuideForAddSensor: Bool
    var router: BaseRouterProtocol
    
    private let roomId: String
    
    init(router: BaseRouterProtocol, roomId: String, isGuideForAddSensor: Bool = true) {
        self.router = router
        self.roomId = roomId
        self.isGuideForAddSensor = isGuideForAddSensor
    }
    
    func next() {
        if isGuideForAddSensor {
            router.enqueueRoute(with: GuideRouter.RouteType.addSensor(self.roomId))
        } else {
            router.enqueueRoute(with: GuideRouter.RouteType.addHeater(self.roomId))
        }
    }
    
    func viewWillAppear() {
        self.guideItems.value =  self.initGuidePages()
    }
    
    private func initGuidePages() -> [GuideItem] {
        var guideItems: [GuideItem] = []
        guideItems.append(GuideItem(image: UIImage(named: "managementIcon"), title: "Caution when setting a room, only turn on one sensor at a time", message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."))
        guideItems.append(GuideItem(image: UIImage(named: "managementIcon"), title: "Turn sensor on by pressing down button.", message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."))
        guideItems.append(GuideItem(image: UIImage(named: "managementIcon"), title: "Close sensor by reattaching top casing and twisting 45 degress.", message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. "))
        guideItems.append(GuideItem(image: UIImage(named: "managementIcon"), title: "Switch on Heater and press button 5 times", message: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. "))
        return guideItems
    }
}

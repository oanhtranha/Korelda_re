//
//  InstructionViewModel.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

protocol InstructionViewModelProtocol: BaseViewModelProtocol {
    var typeInstructions: Variable<[TypeInstruction]>  { get }
    func backToRoot()
    func nextToSensorManagement(roomId: String, roomName: String, isFromRoomConfiguration: Bool)
}
class InstructionViewModel: InstructionViewModelProtocol {
    var typeInstructions: Variable<[TypeInstruction]> = Variable<[TypeInstruction]>([])
    var router: BaseRouterProtocol
    
    init(router: BaseRouterProtocol, typeInstructions: [TypeInstruction]) {
        self.router = router
        self.typeInstructions.value = typeInstructions
    }
    
    func backToRoot() {
        if let router = self.router as? InstructionForSensorRouter {
            router.backToRoot()
        }
    }
    
    func nextToSensorManagement(roomId: String, roomName: String, isFromRoomConfiguration: Bool) {
        if let router = self.router as? InstructionForSensorRouter {
            router.nextToSensorManagement(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
        }
    }
}

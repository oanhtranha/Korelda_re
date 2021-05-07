//
//  InstructionForHeaterViewModel.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

protocol InstructionForHeaterViewModelProtocol: BaseViewModelProtocol {
    var typeInstructions: Variable<[TypeInstruction]>  { get }
    func backToRoot()
    func nextToAddHeater(roomId: String, roomName: String, isFromRoomConfiguration: Bool)

}
class InstructionForHeaterViewModel: InstructionForHeaterViewModelProtocol {
    var router: BaseRouterProtocol
    var typeInstructions: Variable<[TypeInstruction]> = Variable<[TypeInstruction]>([])
    
    init(router: BaseRouterProtocol, typeInstructions: [TypeInstruction]) {
        self.router = router
        self.typeInstructions.value = typeInstructions
    }
    
    func backToRoot() {
        if let router = self.router as? InstructionForHeaterRouter {
            router.backToRoot()
        }
    }
    
    func nextToAddHeater(roomId: String, roomName: String, isFromRoomConfiguration: Bool) {
        if let router = self.router as? InstructionForHeaterRouter {
            router.nextToAddHeater(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
        }
    }
}

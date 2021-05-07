//
//  RafCellLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

protocol RafCellLogicModuleDelegate: class {
    func cellLogicModuleCellForLogicModule(logicModule: RafCellLogicModule) -> UITableViewCell?
}

class RafCellLogicModule: NSObject {
    
    //MARK: - Properties
    
    weak var delegate: RafCellLogicModuleDelegate?
    weak var cell: RafTableViewCell?
    
    var cellIdentifier: String {
        //for subclass
        return ""
    }
    
    var actualCellHeight: CGFloat?
    
    func getEstimatedCellHeight() -> CGFloat {
        //will be overridden with better estimation
        return 100
    }
    
    var cellType: RafCellLogicModule.Type {
        return RafCellLogicModule.self
    }
}

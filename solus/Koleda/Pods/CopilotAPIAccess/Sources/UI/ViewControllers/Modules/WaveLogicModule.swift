//
//  WaveLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

class WaveLogicModule: RafCellLogicModule {
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return "WaveTableViewCell"
        }
    }
    
    override var cellType: RafCellLogicModule.Type {
        return WaveLogicModule.self
    }
}

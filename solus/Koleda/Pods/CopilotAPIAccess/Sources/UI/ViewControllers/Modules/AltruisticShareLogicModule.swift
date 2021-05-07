//
//  AltruisticShareLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

class AltruisticShareLogicModule: RafCellLogicModule {
    
    let altruisticProgram: AltruisticProgram
    
    init(altruisticProgram: AltruisticProgram) {
        self.altruisticProgram = altruisticProgram
    }
    
    var altruisticDescription: String {
        return altruisticProgram.description
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return AltruisticShareTableViewCell.stringFromClass()
        }
    }
}

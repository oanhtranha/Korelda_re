//
//  HeaderRafLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class RafHeaderLogicModule: RafCellLogicModule {

    let rafProgram: RafProgram
    
    init(rafProgram: RafProgram) {
        self.rafProgram = rafProgram
    }
    
    var topBannerText: String {
        return rafProgram.bannerText
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return TopRafTableViewCell.stringFromClass()
        }
    }
    
    override var cellType: RafCellLogicModule.Type {
        return RafHeaderLogicModule.self
    }
}

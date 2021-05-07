//
//  RafFooterLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class RafFooterLogicModule: RafCellLogicModule {
    
    let staticData: StaticData
    
    init(staticData: StaticData) {
        self.staticData = staticData
    }
    
    var termsURLString: String? {
        return staticData.termsOfUseUrl
    }
    
    var rafCompanyDetailsString: String {
        return staticData.footerTitle
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return BottomRafTableViewCell.stringFromClass()
        }
    }
}

//
//  TopRafTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class TopRafTableViewCell: RafTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        if let logicModule = logicModule as? RafHeaderLogicModule {
            label.text = logicModule.topBannerText
        }
    }

}

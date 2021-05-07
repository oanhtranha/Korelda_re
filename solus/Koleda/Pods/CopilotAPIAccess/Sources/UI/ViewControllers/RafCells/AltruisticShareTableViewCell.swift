//
//  AltruisticShareTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

class AltruisticShareTableViewCell: RafTableViewCell {
    
    //MARK: - Properties
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        if let logicModule = logicModule as? AltruisticShareLogicModule {
            descriptionLabel.text = logicModule.altruisticDescription
        }
    }
    
}

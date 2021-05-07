//
//  RafTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

protocol RafTableViewCellDelegate: class { }

class RafTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    weak var logicModule: RafCellLogicModule?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate? = nil) {
        self.logicModule = logicModule
    }
}

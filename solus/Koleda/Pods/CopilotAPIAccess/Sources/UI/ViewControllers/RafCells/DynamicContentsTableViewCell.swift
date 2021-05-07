//
//  DynamicContentsTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 18/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class DynamicContentsTableViewCell: RafTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var dynamicContentsLogicModule: DynamicDataLogicModule?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }

    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        dynamicContentsLogicModule = logicModule as? DynamicDataLogicModule
        
        if let logicModule = logicModule as? DynamicDataLogicModule {
            self.tableView.dataSource = logicModule
            self.tableView.delegate = logicModule
            tableViewHeightConstraint.constant = logicModule.tableViewHeight
            
            if let title = logicModule.dynamicDataTitle {
                titleLabel.isHidden = false
                titleLabel.text = title
            }
        }
    }

}

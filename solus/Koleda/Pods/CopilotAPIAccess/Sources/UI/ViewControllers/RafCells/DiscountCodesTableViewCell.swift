//
//  DiscountCodesTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

protocol DiscountCodesTableViewCellDelegate: RafTableViewCellDelegate {
}

class DiscountCodesTableViewCell: RafTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var noCodesView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        if let logicModule = logicModule as? DiscountCodesLogicModule {
            self.tableView.dataSource = logicModule
            tableViewHeightConstraint.constant = logicModule.tableViewHeight
            tableView.isHidden = logicModule.hasDiscountCodes
            noCodesView.isHidden = !logicModule.hasDiscountCodes
            
            descriptionLabel.text = !logicModule.hasDiscountCodes ? LocalizationHelper.translatedStringForKey(key: Strings.Raf.discountCodesDescription.rawValue) : LocalizationHelper.translatedStringForKey(key: Strings.Raf.noDiscountCodesDescription.rawValue)
            descriptionLabel.textColor = !logicModule.hasDiscountCodes ? .discountCodesDescriptionTextColor : .noDiscountCodesDescriptionTextColor
        }
    }

}

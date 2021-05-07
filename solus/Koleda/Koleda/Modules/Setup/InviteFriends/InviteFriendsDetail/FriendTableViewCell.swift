//
//  FriendTableViewCell.swift
//  Koleda
//
//  Created by Oanh Tran on 7/30/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit


class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var abbEmailLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var removeButtonHandler: ((String) -> Void)? = nil
 
    
    @IBAction func remove(_ sender: Any) {
        if let email = emailLabel.text {
            removeButtonHandler?(email)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func loadData(email:String) {
        invitedLabel.text = "INVITED_TEXT".app_localized
        removeButton.setTitle("REMOVE_TEXT".app_localized, for: .normal)
        emailLabel.text = email
        abbEmailLabel.text = email.first?.uppercased()
    }

}

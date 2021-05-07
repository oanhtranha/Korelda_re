//
//  ScheduleRoomCell.swift
//  Koleda
//
//  Created by Oanh tran on 11/1/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleRoomCell: UITableViewCell {
    
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    private var room: Room?
    var closeButtonHandler: ((Room) -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func close(_ sender: Any) {
        if let room = self.room {
            self.closeButtonHandler?(room)
        }
    }
    
    func setup(withRoom: Room) {
        self.room = withRoom
        self.roomName.text = withRoom.name
    }
}

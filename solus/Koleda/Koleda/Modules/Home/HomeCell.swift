//
//  HomeCell.swift
//  Koleda
//
//  Created by Oanh tran on 7/15/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SwiftRichString

class HomeCell: UITableViewCell {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var infoMessageLabel: UILabel!
    @IBOutlet weak var roomTypeImageView: UIImageView!
    @IBOutlet weak var batteryView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    

    @IBOutlet weak var oCLabel: UILabel!
    @IBOutlet weak var turnedOnView: UIView!
    @IBOutlet weak var turnedOffView: UIView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    private var roomViewModel: RoomViewModel?
    let normal = SwiftRichString.Style{
        $0.font = UIFont.app_SFProDisplayMedium(ofSize: 12)
        $0.color = UIColor.hex7e7d80
    }
    
    let smallBold = SwiftRichString.Style {
        $0.font = UIFont.app_FuturaPTDemi(ofSize: 16)
        $0.color = UIColor.hex1F1B15
    }
    
    let bold = SwiftRichString.Style {
        $0.font = UIFont.app_FuturaPTDemi(ofSize: 20)
        $0.color = UIColor.hex1F1B15
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadData(room: RoomViewModel) {
//        Style.View.shadowStyle1.apply(to: subContentView)
        self.roomViewModel = room
        let turnOn = room.onOffSwitchStatus
        roomNameLabel.text = room.roomName
        tempLabel.text =  room.temprature
        roomTypeImageView.image = room.roomHomeImage
        roomTypeImageView.tintColor = UIColor.white
        batteryView.isHidden = !room.isLowBattery
        roomNameLabel.textColor = turnOn ? UIColor.black : UIColor.white
        let group = StyleGroup(base: self.normal, ["h1": self.bold])
        if isEmpty(room.sensor) {
            infoMessageLabel.text = room.infoMessage
            infoMessageLabel.textColor = turnOn ? UIColor.black : UIColor.hex88FFFFFF
        } else {
            infoMessageLabel.attributedText = room.infoMessage.set(style: group)
        }
        oCLabel.textColor = turnOn ? UIColor.hex1F1B15 : UIColor.hex44FFFFFF
        tempLabel.textColor = turnOn ? UIColor.hex1F1B15 : UIColor.white
        let currentTemp = room.currentTemp ?? 0
        let setTemp = Double.valueOf(clusterValue: room.settingTemprature)
        let statusText = currentTemp < setTemp ? "HEATING_UP_TEXT".app_localized : (currentTemp > setTemp) ? "COOLING_DOWN_TEXT".app_localized : ""
        let statusImage: String = currentTemp < setTemp ? "ic-heating-up" : (currentTemp > setTemp) ? "ic-cooling-down" : ""
        var backgroundImage: String = "bg-dark-gradient"
        if turnOn {
            backgroundImage = currentTemp < setTemp ? "bg-warm-gradient" : (currentTemp > setTemp) ? "bg-subtle-gradient" : ""
        }
        statusTitleLabel.text = statusText
        statusImageView.isHidden = currentTemp == setTemp
        statusImageView.image = UIImage(named: statusImage)
        backgroundImageView.isHidden = backgroundImage == ""
        roomTypeImageView.tintColor = backgroundImage == "" ? UIColor.gray : UIColor.white
        backgroundImageView.image = UIImage(named: backgroundImage)
        guard !isEmpty(room.sensor) else {
            turnedOffView.isHidden = false
            turnedOnView.isHidden = true
            return
        }
        turnedOffView.isHidden = turnOn
        turnedOnView.isHidden = !turnOn
      
    }
}

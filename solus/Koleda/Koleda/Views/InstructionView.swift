//
//  InstructionView.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/14/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SwiftRichString

enum TypeInstruction {
    case instructionForSensor1
    case instructionForSensor2
    case instructionForSensor3
    case instructionForSensor4
    case instructionForSensor5
    case instructionForSensor6
    case instructionForHeater1
    case instructionForHeater2
    case instructionForHeater3
    case instructionForHeater4
}

class InstructionView: UIView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var instructionImageView: UIImageView!
    @IBOutlet weak var heighInstructionConstraint: NSLayoutConstraint!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UITextView!
    var styleGroup:StyleGroup!
    var styleGroupForSubTitle:StyleGroup!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kld_loadContentFromNib()
        initView()
    }
    
    func initView() {
        var fontSize: CGFloat = 24
        if UIDevice.screenType == .iPhones_5_5s_5c_SE {
            fontSize = 16
            heighInstructionConstraint.constant = 275
        }
        
        let normal = SwiftRichString.Style {
            $0.font = UIFont.app_SFProDisplaySemibold(ofSize: fontSize)
            $0.color = UIColor.hex1F1B15
        }
        
        let bold = SwiftRichString.Style {
            $0.font = UIFont.app_SFProDisplaySemibold(ofSize: fontSize)
            $0.color = UIColor.hexFF7020
        }
        
        let normalSub = SwiftRichString.Style {
            $0.font = UIFont.app_SFProDisplayRegular(ofSize: 14)
            $0.color = UIColor.gray
        }
        
        let boldAndBlack = SwiftRichString.Style {
            $0.font = UIFont.app_SFProDisplaySemibold(ofSize: 14)
            $0.color = UIColor.black
        }
        
        styleGroup = StyleGroup(base: normal, ["h": bold])
        styleGroupForSubTitle = StyleGroup(base: normalSub, ["b" : boldAndBlack])
    }
    
    func updateUI(type: TypeInstruction) {
        var title: String
        var subTitle: String
        var instructionImage: String
        var backgroundColor: UIColor = .clear
        switch type {
        case .instructionForSensor1:
            backgroundColor = UIColor(hex: 0x252525)
            instructionImage = "ic-instruction-sensor-1"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_1".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_1".app_localized
        case .instructionForSensor2:
            backgroundColor = UIColor(hex: 0x252525)
            instructionImage = "ic-instruction-sensor-2"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_2".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_2".app_localized
        case .instructionForSensor3:
            backgroundColor = UIColor(hex: 0x252525)
            instructionImage = "ic-instruction-sensor-3"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_3".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_3".app_localized
        case .instructionForSensor4:
            backgroundColor = UIColor(hex: 0x252525)
            instructionImage = "ic-instruction-sensor-4"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_4".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_4".app_localized
        case .instructionForSensor5:
            backgroundColor = UIColor(hex: 0x252525)
            instructionImage = "ic-instruction-sensor-5"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_5".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_5".app_localized
        case .instructionForSensor6:
            backgroundColor = UIColor(hex: 0xE6EAF0)
            instructionImage = "ic-instruction-sensor-6"
            title = "ADD_SENSOR_INSTRUCTION_TITLE_6".app_localized
            subTitle = "ADD_SENSOR_INSTRUCTION_SUB_TITLE_6".app_localized
        case .instructionForHeater1:
//            backgroundColor = UIColor(hex: 0xE6EAF0)
            instructionImage = "ic-instruction-heater-1"
            title = "ADD_HEATER_INSTRUCTION_TITLE_1".app_localized
            subTitle = "ADD_HEATER_INSTRUCTION_SUB_TITLE_1".app_localized
        case .instructionForHeater2:
//            backgroundColor = UIColor(hex: 0xE6EAF0)
            instructionImage = "ic-instruction-heater-2"
            title = "ADD_HEATER_INSTRUCTION_TITLE_2".app_localized
            subTitle = "ADD_HEATER_INSTRUCTION_SUB_TITLE_2".app_localized
        case .instructionForHeater3:
//            backgroundColor = UIColor(hex: 0xE6EAF0)
            instructionImage = "ic-instruction-heater-3"
            title = "ADD_HEATER_INSTRUCTION_TITLE_3".app_localized
            subTitle = "ADD_HEATER_INSTRUCTION_SUB_TITLE_3".app_localized
        case .instructionForHeater4:
//            backgroundColor = UIColor(hex: 0xE6EAF0)
            instructionImage = "ic-instruction-heater-4"
            title = "ADD_HEATER_INSTRUCTION_TITLE_4".app_localized
            subTitle = "ADD_HEATER_INSTRUCTION_SUB_TITLE_4".app_localized
        }
        backgroundView.backgroundColor = backgroundColor
        instructionImageView.image = UIImage(named:instructionImage)
        titelLabel.attributedText = title.set(style: styleGroup)
        subTitleLabel.attributedText = subTitle.set(style: styleGroupForSubTitle)
    }
}

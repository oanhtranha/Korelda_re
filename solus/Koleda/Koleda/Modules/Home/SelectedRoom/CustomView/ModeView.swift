//
//  ModeView.swift
//  Koleda
//
//  Created by Oanh tran on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

struct ModeItem {
    let mode: SmartMode
    let title: String
    let icon: UIImage?
    let temperature: Double
    let color: UIColor
    
    init(mode: SmartMode, title: String, icon: UIImage?, temp: Double) {
        self.mode = mode
        self.title = title
        self.icon = icon
        self.temperature = temp
        switch mode {
        case .ECO:
            self.color = UIColor.purpleLight
        case .NIGHT:
            self.color = UIColor.redLight
        case .COMFORT:
            self.color = UIColor.blueLight
        case .SMARTSCHEDULE:
            self.color = UIColor.yellowLight
        default:
            self.color = UIColor.yellowLight
        }
    }
    
    static func imageOf(smartMode: SmartMode) -> UIImage? {
        switch smartMode {
        case .ECO:
            return UIImage.init(named: "ecoMode")
        case .COMFORT:
            return UIImage.init(named: "comfortMode")
        case .NIGHT:
            return UIImage.init(named: "nightMode")
        case .SMARTSCHEDULE:
            return UIImage.init(named: "smartSchedule")
        default:
            return nil
        }
    }
    
    static func titleOf(smartMode: SmartMode) -> String {
        switch smartMode {
        case .ECO:
            return "ECO_MODE_TEXT".app_localized.uppercased()
        case .COMFORT:
            return "COMFORT_MODE_TEXT".app_localized.uppercased()
        case .NIGHT:
            return "NIGHT_MODE_TEXT".app_localized.uppercased()
        case .SMARTSCHEDULE:
            return "SCHEDULE_TEXT".app_localized.uppercased()
        default:
            return ""
        }
    }
    
    static func modeNameOf(smartMode: SmartMode) -> String {
        switch smartMode {
        case .ECO:
            return "ECO_MODE_TEXT".app_localized
        case .COMFORT:
            return "COMFORT_MODE_TEXT".app_localized
        case .NIGHT:
            return "NIGHT_MODE_TEXT".app_localized
        default:
            return ""
        }
    }
    
    static func getModeItem(with smartMode: SmartMode) -> ModeItem? {
        let modeItems = UserDataManager.shared.settingModes
        return modeItems.filter { $0.mode == smartMode}.first
    }
    
    static func getSmartScheduleMode() -> ModeItem {
        return ModeItem(mode: .SMARTSCHEDULE, title: ModeItem.titleOf(smartMode: .SMARTSCHEDULE), icon: ModeItem.imageOf(smartMode: .SMARTSCHEDULE), temp: Constants.DEFAULT_TEMPERATURE)
    }
    
}

class ModeView: UIView {
    
    func setUp(modeItem: ModeItem) {
        self.modeItem = modeItem
        updateStatus(enable: false)
    }
    
    @IBOutlet weak var modeIconImageView: UIImageView!
    @IBOutlet weak var titleModeLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    var modeItem: ModeItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kld_loadContentFromNib()
    }
    
    func updateStatus(enable: Bool, fromModifyModesScreen: Bool = false) {
        guard let modeItem = modeItem else {
            return
        }
        self.titleModeLabel.text = modeItem.title
        self.modeIconImageView.image = modeItem.icon
        self.modeIconImageView.tintColor = (enable || fromModifyModesScreen) ? modeItem.color : UIColor.gray
        self.backgroundColor = enable ? UIColor.white : UIColor.clear
        self.titleModeLabel.textColor = enable ? UIColor.black : UIColor.lightGray
        self.lineLabel.backgroundColor = enable ? modeItem.color : UIColor.clear
    }
    
}

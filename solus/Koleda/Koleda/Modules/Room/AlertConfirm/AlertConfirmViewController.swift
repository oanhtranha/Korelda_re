//
//  AlertConfirmViewController.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/14/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

enum TypeAlert {
    case deleteRoom(icon: UIImage, roomName: String)
    case confirmDeleteRoom
    case deleteSensor(sensorName: String)
    case confirmDeleteSensor
    case deleteHeater(heaterName: String)
    case confirmDeleteHeater
}

typealias OnClickLetfButton = () -> Void
typealias OnClickRightButton = () -> Void

class AlertConfirmViewController: UIViewController {
    
    @IBOutlet weak var deleteRoomView: UIView!
    @IBOutlet weak var deleteRoomTitleLabel: UILabel!
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var confirmDeleteRoomView: UIView!
    @IBOutlet weak var deleleRoomConfirmContinueLabel: UILabel!
    
   
    @IBOutlet weak var deleteSensorView: UIView!
    @IBOutlet weak var deleteSensorTitleLabel: UILabel!
    @IBOutlet weak var confirmDeleteAllSensorsAndHeatersLabel: UILabel!
    
    @IBOutlet weak var sensorImageView: UIImageView!
    @IBOutlet weak var sensorNameLabel: UILabel!
    @IBOutlet weak var activeSensorLabel: UILabel!
    @IBOutlet weak var deleleSensorConfirmContinueLabel: UILabel!
    @IBOutlet weak var areYourSureDeleteSensorLabel: UILabel!
    @IBOutlet weak var confirmDeleteSensorView: UIView!
    
    @IBOutlet weak var deleteHeaterView: UIView!
    @IBOutlet weak var deleteHeaterTitleLabel: UILabel!
    @IBOutlet weak var heaterNameLabel: UILabel!
    @IBOutlet weak var deleleHeaterConfirmContinueLabel: UILabel!
    @IBOutlet weak var confirmDeleteHeaterView: UIView!
    @IBOutlet weak var areYourSureDeleteHeaterLabel: UILabel!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var typeAlert: TypeAlert!
    
    var onClickLetfButton: OnClickLetfButton?
    var onClickRightButton: OnClickRightButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(type: typeAlert)
    }
    
    func initView() {
        deleteRoomView.isHidden = true
        confirmDeleteRoomView.isHidden = true
        deleteSensorView.isHidden = true
        confirmDeleteSensorView.isHidden = true
        deleteHeaterView.isHidden = true
        confirmDeleteHeaterView.isHidden = true
        
        deleteRoomTitleLabel.text = "YOU_ARE_ABOUT_TO_DELETE".app_localized
        deleleRoomConfirmContinueLabel.text = "DO_YOU_WANT_TO_CONTINUE".app_localized
        deleteSensorTitleLabel.text = "YOU_ARE_ABOUT_TO_DELETE".app_localized
        confirmDeleteAllSensorsAndHeatersLabel.text = "ALL_SENSORS_HEATERS_WILL_BE_REMOVED_MESS".app_localized
        activeSensorLabel.text = "ACTIVE_TEXT".app_localized
        deleleSensorConfirmContinueLabel.text = "DO_YOU_WANT_TO_CONTINUE".app_localized
        areYourSureDeleteSensorLabel.text = "CONFIRM_DELETE_SENSOR_MESS".app_localized
        deleteHeaterTitleLabel.text = "YOU_ARE_ABOUT_TO_DELETE".app_localized
        deleleHeaterConfirmContinueLabel.text = "DO_YOU_WANT_TO_CONTINUE".app_localized
        areYourSureDeleteHeaterLabel.text = "CONFIRM_DELETE_HEATER_MESS".app_localized
        leftButton.setTitle("YES_TEXT".app_localized, for: .normal)
        rightButton.setTitle("NO_TEXT".app_localized, for: .normal)
    }
    
    private func updateUI(type: TypeAlert) {
        initView()
        switch type {
        case .deleteRoom(let icon, let roomName):
            deleteRoomView.isHidden = false
            roomImageView.image = icon
            roomNameLabel.text = roomName
        case .confirmDeleteRoom:
            confirmDeleteRoomView.isHidden = false
            leftButton.setTitle("CANCEL".app_localized, for: .normal)
            rightButton.setTitle("DELETE_TEXT".app_localized, for: .normal)
            rightButton.setTitleColor(UIColor(hex: 0xFF7020), for: .normal)
        case .deleteSensor(let sensorName):
            deleteSensorView.isHidden = false
            sensorNameLabel.text = sensorName
        case .confirmDeleteSensor:
            confirmDeleteSensorView.isHidden = false
            leftButton.setTitle("CANCEL".app_localized, for: .normal)
            rightButton.setTitle("DELETE_TEXT".app_localized, for: .normal)
            rightButton.setTitleColor(UIColor(hex: 0xFF7020), for: .normal)
        case .deleteHeater(let  heaterName):
            deleteHeaterView.isHidden = false
            heaterNameLabel.text = heaterName
        case .confirmDeleteHeater:
            confirmDeleteHeaterView.isHidden = false
            leftButton.setTitle("CANCEL".app_localized, for: .normal)
            rightButton.setTitle("DELETE_TEXT".app_localized, for: .normal)
            rightButton.setTitleColor(UIColor(hex: 0xFF7020), for: .normal)
        }
    }

    @IBAction func leftClickAction(_ sender: Any) {
        back(animated: false)
        onClickLetfButton?()
    }
    @IBAction func rightClickAction(_ sender: Any) {
        back(animated: false)
        onClickRightButton?()
    }
}

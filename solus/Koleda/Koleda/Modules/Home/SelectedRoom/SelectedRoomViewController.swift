//
//  SelectedRoomViewController.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD
import SwiftRichString

class SelectedRoomViewController: BaseViewController, BaseControllerProtocol {
	
    @IBOutlet weak var onOffSwitchButton: UIButton!
    @IBOutlet weak var onOffSwitchLabel: UILabel!
    @IBOutlet weak var onOffSwitchImageView: UIImageView!
	
    @IBOutlet weak var userHomeTitle: UILabel!
    @IBOutlet weak var temperatuteTitleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityTitleLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
	
    @IBOutlet weak var ecoModeView: ModeView!
    @IBOutlet weak var ecoModeButton: UIButton!
    @IBOutlet weak var nightModeView: ModeView!
    @IBOutlet weak var nightModeButton: UIButton!
    @IBOutlet weak var comfortModeView: ModeView!
    @IBOutlet weak var comfortModeButton: UIButton!
    @IBOutlet weak var smartScheduleModeView: ModeView!
    @IBOutlet weak var smartScheduleModeButton: UIButton!
	
    @IBOutlet weak var temperatureCircleSlider: SSCircularRingSlider!
    @IBOutlet weak var startTemperatureLabel: UILabel!
    @IBOutlet weak var endTemperatureLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var editingTempratureLabel: UILabel!
    @IBOutlet weak var editingTempraturesmallLabel: UILabel!
	
	@IBOutlet weak var plusTempButton: UIButton!
	@IBOutlet weak var minusTempButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timeSlider: CustomSlider!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var countDownTimeLabel: UILabel!
    

   
	@IBOutlet weak var configurationButton: UIButton!
    

    private let disposeBag = DisposeBag()
    
    var viewModel: SelectedRoomViewModelProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.setup()
	}
	
	fileprivate func setCircularRingSliderColor(arrayValues: [Int]) {
        let currentValue = viewModel.currentValueSlider
        temperatureCircleSlider.setValues(initialValue: currentValue.toCGFloat(), minValue: arrayValues[0].toCGFloat(), maxValue: arrayValues[arrayValues.count - 1].toCGFloat())
        temperatureCircleSlider.setProgressLayerColor(colors: [UIColor.orange.cgColor, UIColor.orange.cgColor])
        temperatureCircleSlider.setCircluarRingColor(innerCirlce: UIColor.lightGray, outerCircle: UIColor.orange)
        temperatureCircleSlider.setCircularRingWidth(innerRingWidth: 2, outerRingWidth: 2)
        viewModel.temperatureSliderChanged(value: currentValue)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func needUpdateSelectedRoom() {
        viewModel.needUpdateSelectedRoom()
    }
    
    @IBAction func turnOnOffAction(_ sender: Any) {
        SVProgressHUD.show()
        viewModel.turnOnOrOffRoom { [weak self] turnOn, isSuccess in
            SVProgressHUD.dismiss()
            if !isSuccess {
                let status = turnOn ? "TURN_ON_TEXT".app_localized : "TURN_OFF_TEXT".app_localized
                let message = String(format: "ADD_ROOM_ERROR_MESSAGE".app_localized, status)
                self?.app_showInfoAlert(message)
            }
        }
    }
	
	@objc func changeVlaue(slider: UISlider, event: UIEvent) {
		if let touchEvent = event.allTouches?.first {
			switch touchEvent.phase {
			case .began:
				break;
			case .moved:
				viewModel.updateSettingTime(seconds: Int(slider.value))
			case .ended:
				viewModel.checkForAutoUpdateManualBoost(updatedTemp: false)
			default:
				break
			}
		}
	}
	
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateSelectedRoom),
                                               name: .KLDNeedUpdateSelectedRoom, object: nil)
        
        configurationButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.showConfigurationScreen()
        }.disposed(by: disposeBag)
        viewModel.homeTitle.asObservable().bind(to: userHomeTitle.rx.text).disposed(by: disposeBag)
        viewModel.temperature.asObservable().bind(to: temperatureLabel.rx.text).disposed(by: disposeBag)
        viewModel.humidity.asObservable().bind(to: humidityLabel.rx.text).disposed(by: disposeBag)
        viewModel.modeItems.asObservable().bind { [weak self] modeItems in
            guard let eco =  ModeItem.getModeItem(with: .ECO), let night = ModeItem.getModeItem(with: .NIGHT), let comfort = ModeItem.getModeItem(with: .COMFORT) else {
                return
            }
            self?.ecoModeView.setUp(modeItem: eco)
            self?.nightModeView.setUp(modeItem: night)
            self?.comfortModeView.setUp(modeItem: comfort)
            let smartSchedule = ModeItem.getSmartScheduleMode()
            self?.smartScheduleModeView.setUp(modeItem: smartSchedule)
        }.disposed(by: disposeBag)
        
        ecoModeButton.rx.tap.bind { [weak self] _ in
            self?.checkBeforeUpdateSmartMode(selectedMode: .ECO)
        }.disposed(by: disposeBag)
        comfortModeButton.rx.tap.bind { [weak self] _ in
            self?.checkBeforeUpdateSmartMode(selectedMode: .COMFORT)
        }.disposed(by: disposeBag)
        nightModeButton.rx.tap.bind { [weak self] _ in
            self?.checkBeforeUpdateSmartMode(selectedMode: .NIGHT)
        }.disposed(by: disposeBag)
        smartScheduleModeButton.rx.tap.bind { [weak self] _ in
            self?.checkBeforeUpdateSmartMode(selectedMode: .SMARTSCHEDULE)
        }.disposed(by: disposeBag)
        
        viewModel.ecoModeUpdate.asObservable().subscribe(onNext: { [weak self] enable in
            self?.ecoModeView.updateStatus(enable: enable)
        }).disposed(by: disposeBag)
        viewModel.comfortModeUpdate.asObservable().subscribe(onNext: { [weak self] enable in
            self?.comfortModeView.updateStatus(enable: enable)
        }).disposed(by: disposeBag)
        viewModel.nightModeUpdate.asObservable().subscribe(onNext: { [weak self] enable in
            self?.nightModeView.updateStatus(enable: enable)
        }).disposed(by: disposeBag)
        viewModel.smartScheduleModeUpdate.asObservable().subscribe(onNext: { [weak self] enable in
            self?.smartScheduleModeView.updateStatus(enable: enable)
        }).disposed(by: disposeBag)
		viewModel.turnOnRoom.asObservable().subscribe(onNext: { [weak self] turnOn in
            self?.onOffSwitchImageView.image = UIImage(named: turnOn ? "ic-switch-on": "ic-switch-off")
            self?.onOffSwitchButton.isSelected = turnOn
            self?.onOffSwitchLabel.text = turnOn ? "ON_TEXT".app_localized.uppercased() : "OFF_TEXT".app_localized.uppercased()
            self?.onOffSwitchLabel.textColor = turnOn ? UIColor.black : UIColor.gray
        }).disposed(by: disposeBag)
		//
        
        timeSlider.maximumValue = Float(Constants.MAX_END_TIME_POINT + 1)
        timeSlider.minimumValue = 0
        timeSlider.addTarget(self, action: #selector(changeVlaue(slider:event:)), for: .valueChanged)
        viewModel.performBoosting.asObservable().subscribe(onNext: { [weak self] _ in
            guard let time = self?.viewModel.timeSliderValue.value, Int(time) > 0 else {
                self?.app_showInfoAlert("PLEASE_SET_A_TIMER_FOR_MANUAL_BOOST_MESS".app_localized)
                return
            }
            SVProgressHUD.show(withStatus: "UPDATING_MANUAL_BOOST_TEXT".app_localized)
            self?.viewModel.manualBoostUpdate(completion: { [weak self] isSuccess in
                SVProgressHUD.dismiss()
                if isSuccess {
                    NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                    self?.app_showInfoAlert("MANUAL_BOOST_UPDATE_SUCCESS_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                        self?.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self?.app_showInfoAlert("MANUAL_BOOST_CAN_NOT_UPDATE_MESS".app_localized)
                }})
        }).disposed(by: disposeBag)
        
        viewModel.canAdjustTemp.asObservable().subscribe(onNext: { [weak self] value in
            self?.resetButton.isEnabled = value
            self?.temperatureCircleSlider.isEnable = value
			self?.plusTempButton.isEnabled = value
			self?.minusTempButton.isEnabled = value
        }).disposed(by: disposeBag)
        
        viewModel.refreshTempCircleSlider.asObservable().subscribe(onNext: { [weak self] in
            guard let temperatureRange = self?.viewModel.temperatureSliderRange else {
                return
            }
            self?.temperatureCircleSlider.delegate = self
            self?.setCircularRingSliderColor(arrayValues: temperatureRange)
        }).disposed(by: disposeBag)
        viewModel.turnOnManualBoost.asObservable().bind(onNext: { [weak self] turnOn in
            self?.timerView.isHidden = !turnOn
        }).disposed(by: disposeBag)
        resetButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.resetManualBoost(completion: { success, errorMessage in
                guard success else {
                    if errorMessage != "" {
                        self?.app_showInfoAlert(errorMessage)
                    }
                    return
                }
                self?.app_showInfoAlert("RESET_BOOSTING_SUCCESS_MESS".app_localized)
                NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            })
        }.disposed(by: disposeBag)
        
		viewModel.countDownTime.asObservable().bind { [weak self] value in
			self?.countDownTimeLabel.text = value
			}.disposed(by: disposeBag)
		
		viewModel.endTime.asObservable().bind(to: endTimeLabel.rx.text).disposed(by: disposeBag)
		
		viewModel.timeSliderValue.asObservable().bind { [weak self] value in
			self?.timeSlider.setValue(value, animated: true)
        }.disposed(by: disposeBag)
		viewModel.startTemprature.asObservable().bind { [weak self] value in
			self?.startTemperatureLabel.text = String(value)
		}.disposed(by: disposeBag)
		viewModel.endTemprature.asObservable().bind { [weak self] value in
			self?.endTemperatureLabel.text = String(value)
		}.disposed(by: disposeBag)
		
		viewModel.editingTemprature.asObservable().bind { [weak self] value in
			self?.editingTempratureLabel.text = String(value)
		}.disposed(by: disposeBag)
			   
	    viewModel.editingTempratureSmall.asObservable().bind { [weak self] value in
		   self?.editingTempraturesmallLabel.text =  value > 0 ? ".\(value)" : ""
	    }.disposed(by: disposeBag)
	   
	    viewModel.statusText.asObservable().bind(to: statusLabel.rx.text).disposed(by: disposeBag)
	    viewModel.statusImageName.asObservable().bind { [weak self] imageName in
		   self?.statusImageView.isHidden = imageName == ""
		   self?.statusImageView.image = UIImage(named: imageName)
	    }.disposed(by: disposeBag)
        viewModel.manualBoostTimeout.asObservable().subscribe(onNext: { [weak self] in
            SVProgressHUD.show(withStatus: "MANUAL_BOOST_TIMEOUT_TEXT".app_localized)
            self?.viewModel.refreshRoom(completion: { success in
                SVProgressHUD.dismiss()
            })
        }).disposed(by: disposeBag)
		
		plusTempButton.rx.tap.bind { [weak self] _ in
			self?.viewModel.adjustTemprature(increased: true)
		}.disposed(by: disposeBag)
		
		minusTempButton.rx.tap.bind { [weak self] _ in
			self?.viewModel.adjustTemprature(increased: false)
		}.disposed(by: disposeBag)
        
        configurationButton.setTitle("ROOM_SETTINGS_TEXT".app_localized, for: .normal)
        temperatuteTitleLabel.text = "TEMPERATURE_TEXT".app_localized.uppercased()
        humidityTitleLabel.text = "HUMIDITY_TEXT".app_localized.uppercased()
        resetButton.setTitle("CANCEL".app_localized, for: .normal)
    }
    
    private func checkBeforeUpdateSmartMode(selectedMode: SmartMode) {
        guard viewModel.heaters.count > 0  else {
            app_showInfoAlert("CHANGE_MODE_IS_NOT_POSSIBLE_MESS".app_localized)
            return
        }
        
        if viewModel.settingType == .MANUAL {
			SVProgressHUD.show()
			viewModel.resetManualBoost { [weak self] (success, _) in
				SVProgressHUD.dismiss()
				guard success else {
                    self?.app_showInfoAlert("CAN_NOT_UPDATE_MODE_MESS".app_localized)
					return
				}
				self?.updateSettingMode(selectedMode: selectedMode)
				NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
			}
        } else if selectedMode == .SMARTSCHEDULE {
            updateScheduleMode()
        } else {
            updateSettingMode(selectedMode: selectedMode)
        }
    }
    
    private func updateSettingMode(selectedMode: SmartMode) {
        SVProgressHUD.show()
        viewModel.updateSettingMode(mode: selectedMode) { [weak self] (updatedMode, isSuccess, errorMessage)  in
            SVProgressHUD.dismiss()
            if isSuccess {
                NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                self?.viewModel.changeSmartMode(seletedSmartMode: updatedMode)
            } else {
                if !errorMessage.isEmpty {
                    self?.app_showInfoAlert(errorMessage)
                }
            }
        }
    }
    
    private func updateScheduleMode() {
        SVProgressHUD.show()
        viewModel.turnOnOrOffScheduleMode(completion: { [weak self] (isSuccess, errorMessage) in
            SVProgressHUD.dismiss()
            if isSuccess {
                NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                self?.viewModel.changeSmartMode(seletedSmartMode: .SMARTSCHEDULE)
            } else {
                if !errorMessage.isEmpty {
                    self?.app_showInfoAlert(errorMessage)
                }
            }
        })
    }

    @IBAction func backAction(_ sender: Any) {
        back()
    }
}

extension SelectedRoomViewController: SSCircularRingSliderDelegate {
    
    // This function will be called after updating Circular Slider Control value
    func controlValueUpdated(value: Int) {
//        print("current control value \(value)")
        viewModel.temperatureSliderChanged(value: value)
    }
    
    func needUpdate() {
		viewModel.checkForAutoUpdateManualBoost(updatedTemp: true)
    }
    
}

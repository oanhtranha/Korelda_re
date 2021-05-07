//
//  AddHeaterViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class AddHeaterViewController:  BaseViewController, BaseControllerProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
   
    
    
    @IBOutlet weak var searchingHeaterView: UIView!
    @IBOutlet weak var searchingForHeaterLabel: UILabel!
    
    @IBOutlet weak var moreThanOneHeaterView: UIView!
    @IBOutlet weak var moreThanOneHeaterLabel: UILabel!
    @IBOutlet weak var followTheInstructionsToConnectLabel: UILabel!
    @IBOutlet weak var tryAgain2Button: UIButton!
    @IBOutlet weak var tryAgain2Label: UILabel!
    
    @IBOutlet weak var couldNotFindHeaterView: UIView!
    @IBOutlet weak var couldNotFindHeaterLabel: UILabel!
    @IBOutlet weak var connectToDeviceHotspotButton: UIButton!
    
    @IBOutlet weak var reportSearchHeaterView: UIView!
    @IBOutlet weak var haveFoundTitleView: UIView!
    @IBOutlet weak var weHaveFoundOneHeaterLabel: UILabel!
    @IBOutlet weak var tapToConnectLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var aHeaterView: UIView!
    @IBOutlet weak var addHeaterButton: UIButton!
    @IBOutlet weak var deviceModelLabel: UILabel!
    
    @IBOutlet weak var addingHeaterTitleView: UIView!
    @IBOutlet weak var addingHeaterLabel: UILabel!
    @IBOutlet weak var pleaseWatiForAddingLabel: UILabel!
    
    @IBOutlet weak var addSuccessfullyView: UIView!
    @IBOutlet weak var heaterAddedSuccessLabel: UILabel!
    @IBOutlet weak var addedDeviceModelLabel: UILabel!
    @IBOutlet weak var addedRoomNameLabel: UILabel!
    @IBOutlet weak var doYouWantAddOtherLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var viewModel: AddHeaterViewModelProtocol!
    var isFromRoomConfiguration: Bool = false
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startToDectectDevice()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func scanShellyDevices() {
        startToDectectDevice()
    }
    
    private func configurationUI() {
        cancelButton.isHidden = true
        canBackToPreviousScreen = false
        NotificationCenter.default.addObserver(self, selector: #selector(scanShellyDevices), name: .KLDDidChangeWifi, object: nil)
        SVProgressHUD.setDefaultStyle(.dark)
        cancelButton.rx.tap.bind { [weak self] in
            self?.back()
        }.disposed(by: disposeBag)
        viewModel.cancelButtonHidden.asObservable().bind(to: cancelButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.stepAddHeaters.asObservable().subscribe(onNext: { [weak self] status in
            self?.searchingHeaterView.isHidden = true
            self?.moreThanOneHeaterView.isHidden = true
            self?.couldNotFindHeaterView.isHidden = true
            self?.reportSearchHeaterView.isHidden = true
            self?.haveFoundTitleView.isHidden = true
            self?.lineView.isHidden = true
            self?.aHeaterView.isHidden = true
            self?.addingHeaterTitleView.isHidden = true
            self?.addSuccessfullyView.isHidden = true
            
            switch status {
            case .search:
                self?.searchingHeaterView.isHidden = false
                self?.viewModel.cancelButtonHidden.onNext(true)
            case .moreThanOneDevice: //more than one heater 1
                self?.moreThanOneHeaterView.isHidden = false
                self?.viewModel.cancelButtonHidden.onNext(true)
            case .noDevice: //no heater 2
                self?.couldNotFindHeaterView.isHidden = false
                self?.viewModel.cancelButtonHidden.onNext(true)
            case .oneDevice: //found a heater 3
                self?.reportSearchHeaterView.isHidden = false
                self?.haveFoundTitleView.isHidden = false
                self?.lineView.isHidden = false
                self?.aHeaterView.isHidden = false
                self?.deviceModelLabel.text = self?.viewModel.detectedHeaters[0].deviceModel
                self?.addHeaterButton.isEnabled = true
                self?.viewModel.cancelButtonHidden.onNext(true)
            case .addDevice: //adding a heater 4
                self?.reportSearchHeaterView.isHidden = false
                self?.addingHeaterTitleView.isHidden = false
                self?.lineView.isHidden = false
                self?.aHeaterView.isHidden = false
                self?.deviceModelLabel.text = self?.viewModel.detectedHeaters[0].deviceModel
                self?.addHeaterButton.isEnabled = false
                self?.viewModel.cancelButtonHidden.onNext(false)
            case .addDeviceSuccess: //adding a heater successfully 5
                self?.reportSearchHeaterView.isHidden = false
                self?.addSuccessfullyView.isHidden = false
                self?.deviceModelLabel.text = self?.viewModel.detectedHeaters[0].deviceModel
                self?.addHeaterButton.isEnabled = false
                self?.addedDeviceModelLabel.text = self?.viewModel.detectedHeaters[0].deviceModel
                self?.viewModel.cancelButtonHidden.onNext(true)
                if let userName = UserDataManager.shared.currentUser?.name, let roomName = self?.viewModel.roomName {
//                    self?.addedRoomNameLabel.text = "\(userName)’s \(roomName)"
                } else {
//                    self?.addedRoomNameLabel.text = self?.viewModel.roomName
                }
            case .joinDeviceHotSpot:
                self?.viewModel.cancelButtonHidden.onNext(true)
                guard let ssid = UserDefaultsManager.wifiSsid.value, let pass = UserDefaultsManager.wifiPass.value else {
                    self?.viewModel.stepAddHeaters.onNext(.noDevice)
                    self?.app_showInfoAlert("UPDATE_WIFI_SETTINGS_INFO_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                        self?.viewModel.showWifiDetail()
                    })
                    return
                }
                SVProgressHUD.show()
                self?.viewModel.connectHeaterLocalWifi(ssid: ssid, pass: pass, completion: { [weak self] success in
                    SVProgressHUD.dismiss()
                    self?.viewModel.stepAddHeaters.onNext(.noDevice)
                    if success {
                        self?.app_showInfoAlert("HEATER_CONNECTED_TO_YOUR_LOCAL_WIFI_MESS".app_localized, title: "SUCCESSFULL_TEXT".app_localized, completion: {
                            SVProgressHUD.show()
                            self?.viewModel.waitingHeatersJoinNetwork(completion: {
                                SVProgressHUD.dismiss()
                                self?.startToDectectDevice()
                            })
                        })
                    } else {
                        self?.viewModel.stepAddHeaters.onNext(.noDevice)
                        self?.app_showInfoAlert("WIFI_SSID_OR_PASS_IS_INCORRECT_MESS".app_localized, title: "ERROR_TITLE".app_localized, completion: {
                            self?.viewModel.showWifiDetail()
                        })
                    }
                })
            }
            
        }).disposed(by: disposeBag)
        
        addHeaterButton.rx.tap.bind { [weak self] in
            self?.viewModel.stepAddHeaters.onNext(.addDevice)
            self?.viewModel.addAHeaterToARoom { (error, deviceModel, roomName) in
                guard let error = error else {
                    NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                    self?.viewModel.stepAddHeaters.onNext(.addDeviceSuccess)
                    return
                }
                if error == WSError.deviceExisted {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: String(format: "%@ %@", "THIS_HEATER_TEXT".app_localized, error.localizedDescription))
                } else {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_ADD_HEATER_MESS".app_localized)
                }
            }
        }.disposed(by: disposeBag)
        
        tryAgain2Button.rx.tap.bind { [weak self] in
            self?.startToDectectDevice()
        }.disposed(by: disposeBag)
        tryAgainButton.rx.tap.bind { [weak self] in            self?.startToDectectDevice()
        }.disposed(by: disposeBag)
        
        connectToDeviceHotspotButton.rx.tap.bind { [weak self] in
            self?.goWifiSetting()
        }.disposed(by: disposeBag)
        
        viewModel.reSearchingHeater.asObservable().subscribe(onNext: { [weak self] success in
            self?.viewModel.stepAddHeaters.onNext(.noDevice)
            self?.startToDectectDevice()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanShellyDevices),
                                               name: .KLDNeedToReSearchDevices, object: nil)
        titleLabel.text = "ADD_A_HEATER_TEXT".app_localized
        searchingForHeaterLabel.text = "SEARCHING_FOR_HEATER_TEXT".app_localized
        couldNotFindHeaterLabel.text = "COULD_NOT_FIND_HEATER_MESS".app_localized
        connectToDeviceHotspotButton.setTitle("CONNECT_TO_HEATER_HOTSPOT_TEXT".app_localized, for: .normal)
        tryAgainButton.setTitle("RETRY_TEXT".app_localized, for: .normal)
        weHaveFoundOneHeaterLabel.text = "WE_HAVE_FOUND_ONE_HEATER_TEXT".app_localized
        tapToConnectLabel.text = "TAP_TO_CONNECT".app_localized
        addHeaterButton.setTitle("ADD_TEXT".app_localized, for: .normal)
        moreThanOneHeaterLabel.text = "THERE_IS_MORE_THAN_ONE_HEATER_MESS".app_localized
        followTheInstructionsToConnectLabel.text = "FOLLOW_THE_INSTRUCTION_TO_CONNECT".app_localized
        tryAgain2Label.text = "TRY_AGAIN_TEXT".app_localized
        addingHeaterLabel.text = "ADDING_HEATER_TEXT".app_localized
        pleaseWatiForAddingLabel.text = "PLEASE_WAIT_TEXT".app_localized
        heaterAddedSuccessLabel.text = "HEATER_ADDED_SUCCES_MESS".app_localized
        doYouWantAddOtherLabel.text = "ADD_OTHER_HEATER_CONFIRM_MESS".app_localized
        yesButton.setTitle("YES_TEXT".app_localized, for: .normal)
        noButton.setTitle("NO_TEXT".app_localized, for: .normal)
    }
    
    private func goWifiSetting() {
        let OkAction = UIAlertAction(title: "OK".app_localized, style: .default) { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL".app_localized, style: .cancel) { action in
            
        }
        app_showAlertMessage(title: "KOLEDA_TEXT".app_localized,
                             message: "INSTRUCTION_FOR_SELECT_YOUR_HEATER_HOTSPOT_MESS".app_localized, actions: [cancelAction, OkAction])
    }
    
    private func startToDectectDevice() {
        self.view.endEditing(true)
        self.viewModel.stepAddHeaters.onNext(.search)
        let ssid = viewModel.getCurrentWiFiName()
        print(ssid)
        guard FGRoute.getGatewayIP() != nil else {
            if ssid != "" && DataValidator.isShellyHeaterDevice(hostName: ssid) {
                SVProgressHUD.show()
                viewModel.fetchInfoOfHeaderAPMode(completion: { [weak self] success in
                    SVProgressHUD.dismiss()
                    if success {
                        self?.viewModel.stepAddHeaters.onNext(.joinDeviceHotSpot)
                    } else {
                        self?.viewModel.stepAddHeaters.onNext(.noDevice)
                    }
                })
            } else {
                viewModel.stepAddHeaters.onNext(.noDevice)
                NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: nil)
            }
            return
        }
        closeButton?.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.findHeatersOnLocalNetwork {
                if self.viewModel.detectedHeaters.count == 0 {
                    self.viewModel.stepAddHeaters.onNext(.noDevice)
                } else if self.viewModel.detectedHeaters.count > 1 {
                    self.viewModel.stepAddHeaters.onNext(.moreThanOneDevice)
                } else if self.viewModel.detectedHeaters.count == 1 {
                    self.viewModel.stepAddHeaters.onNext(.oneDevice)
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        if isFromRoomConfiguration {
            backToViewControler(viewController: HeatersManagementViewController.self)
        } else {
            backToRoot(animated: true)
        }
    }
    @IBAction func yesAction(_ sender: Any) {
        startToDectectDevice()
    }
    
    @IBAction func noAction(_ sender: Any) {
        if addSuccessfullyView.isHidden == false {
            if isFromRoomConfiguration {
                backToViewControler(viewController: HeatersManagementViewController.self)
            } else {
                backToRoot(animated: true)
            }
        } else {
            back()
        }
    }
}

extension AddHeaterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

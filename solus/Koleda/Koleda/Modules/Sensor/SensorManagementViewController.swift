//
//  SensorManagementViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SVProgressHUD
import RxSwift
import SwiftRichString

class SensorManagementViewController: BaseViewController, BaseControllerProtocol {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusSubTitleLabel: UILabel!
    @IBOutlet weak var sensorModelLabel: UILabel!
    @IBOutlet weak var sensorView: UIView!
    @IBOutlet weak var addedSuccessfullyView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var sensorNameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detectOneSensorView: UIView!
    @IBOutlet weak var addSensorButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var connectToDeviceHotspotButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var isFromRoomConfiguration: Bool = false
    
    let normal = SwiftRichString.Style{
        $0.font = UIFont.SFProDisplaySemibold20
        $0.color = UIColor.white
    }
    
    let bold = SwiftRichString.Style {
        $0.font = UIFont.SFProDisplaySemibold20
        $0.color = UIColor.hexFF7020
    }
    
    var viewModel: SensorManagementViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
}

extension SensorManagementViewController {
    
    private func startToDectectDevice() {
        self.view.endEditing(true)
        viewModel.updateUI(with: .search)
        let ssid = viewModel.getCurrentWiFiName()
        print(ssid)
        guard FGRoute.getGatewayIP() != nil else {
            if ssid != "" && DataValidator.isShellyDevice(hostName: ssid) {
                SVProgressHUD.show()
                viewModel.fetchInfoOfSensorAPMode(completion: { [weak self] success in
                    SVProgressHUD.dismiss()
                    if success {
                        self?.viewModel.updateUI(with: .joinDeviceHotSpot)
                    } else {
                        self?.viewModel.updateUI(with: .noDevice)
                    }
                })
            } else {
                NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: nil)
                self.viewModel.updateUI(with: .noDevice)
            }
            return
        }

        closeButton?.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SVProgressHUD.show()
            self.viewModel.findSensorsOnLocalNetwork { [weak self] in
                SVProgressHUD.dismiss()
                self?.viewModel.updateStatusAfterSeaching()
                self?.closeButton?.isEnabled = true
            }
        }
    }
    
    func configurationUI() {
        doneButton.isHidden = true
        cancelButton.isHidden = true
        nextView.isHidden = true
        titleLabel.attributedText = viewModel.titleAttributed
        roomNameLabel.text = viewModel.roomNameWithUserName
        let group = StyleGroup(base: self.normal, ["h1": self.bold])
        canBackToPreviousScreen = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanShellyDevices),
                                               name: .KLDDidChangeWifi, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scanShellyDevices),
                                               name: .KLDNeedToReSearchDevices, object: nil)
        
        viewModel.statusImage.asObservable().subscribe(onNext: { [weak self] image in
            guard let statusImage = image else {
                self?.statusImageView.isHidden = true
                return
            }
            self?.statusImageView.isHidden = false
            self?.statusImageView.image = statusImage
        }).disposed(by: disposeBag)
        
        viewModel.statusTitle.asObservable().subscribe(onNext: { [weak self] title in
            self?.statusTitleLabel.isHidden = (title == "")
            self?.statusTitleLabel.attributedText = title.set(style: group)
        }).disposed(by: disposeBag)
        
        viewModel.statusSubTitle.asObservable().subscribe(onNext: { [weak self] title in
            self?.statusSubTitleLabel.isHidden = (title == "")
            self?.statusSubTitleLabel.text = title
        }).disposed(by: disposeBag)
        
        viewModel.statusViewHidden.asObservable().bind(to: statusView.rx.isHidden).disposed(by: disposeBag)
        viewModel.tryAgainButtonHidden.asObservable().bind(to: tryAgainButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.connectToDeviceHotspotButtonHidden.asObservable().bind(to: connectToDeviceHotspotButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.cancelButtonHidden.asObservable().bind(to: cancelButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.sensorViewHidden.asObservable().bind(to: sensorView.rx.isHidden).disposed(by: disposeBag)
        viewModel.sensorModel.asObservable().bind(to: sensorModelLabel.rx.text).disposed(by: disposeBag)
        viewModel.addedSuccessfullyViewHidden.asObservable().subscribe(onNext: { [weak self] isHidden in
            guard let `self` = self else {
                return
            }
            self.addedSuccessfullyView.isHidden = isHidden
            if !isHidden {
                self.doneButton.isHidden = !self.isFromRoomConfiguration
                self.nextView.isHidden = self.isFromRoomConfiguration
            }
        }).disposed(by: disposeBag)
        addSensorButton.rx.tap.bind { [weak self] in
            self?.addSensorButton.isEnabled = false
            self?.viewModel.updateUI(with: .addDevice)
            self?.viewModel.addASensorToARoom { error in
                self?.addSensorButton.isEnabled = true
                self?.sensorNameLabel.text = self?.viewModel.sensorName
                guard let error = error else {
                    NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                    self?.viewModel.updateUI(with: .addDeviceSuccess)
                    return
                }
                if error == WSError.deviceExisted {
                    let errorMess = String(format: "%@ %@", "THIS_SENSOR_TEXT".app_localized, error.localizedDescription)
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: errorMess.app_localized)
                } else {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_ADD_SENSOR_MESS".app_localized)
                }
                self?.viewModel.updateStatusAfterSeaching()
            }
        }.disposed(by: disposeBag)
        
        tryAgainButton.rx.tap.bind { [weak self] in
            self?.startToDectectDevice()
        }.disposed(by: disposeBag)
        
        connectToDeviceHotspotButton.rx.tap.bind { [weak self] in
            self?.goWifiSetting()
        }.disposed(by: disposeBag)
        
        viewModel.changeWifiForShellyDevice.asObservable().subscribe(onNext: { [weak self] in
            guard let ssid = UserDefaultsManager.wifiSsid.value, let pass = UserDefaultsManager.wifiPass.value else {
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "UPDATE_WIFI_SETTINGS_INFO_MESS".app_localized)
                return
            }
            self?.joinSensorToWifiNetwork(ssid: ssid, pass: pass)
        }).disposed(by: disposeBag)
        connectToDeviceHotspotButton.setTitle("CONNECT_TO_SENSOR_HOTSPOT_TEXT".app_localized, for: .normal)
        tryAgainButton.setTitle("TRY_AGAIN_TEXT".app_localized, for: .normal)
        cancelButton.setTitle("CANCEL".app_localized, for: .normal)
        addSensorButton.setTitle("ADD_TEXT".app_localized, for: .normal)
        doneButton.setTitle("DONE_TEXT".app_localized, for: .normal)
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
                             message: "INSTRUCTION_FOR_SELECT_YOUR_SENSOR_HOTSPOT_MESS".app_localized, actions: [cancelAction, OkAction])
    }
    
    private func joinSensorToWifiNetwork(ssid: String, pass: String) {
        self.view.endEditing(true)
        SVProgressHUD.show()
        viewModel.connectSensorLocalWifi(ssid: ssid, pass: pass) {  [weak self] isSuccess in
            SVProgressHUD.dismiss()
            if isSuccess {
                self?.viewModel.updateUI(with: .search)
                self?.app_showInfoAlert("SENSOR_CONNECTED_TO_YOUR_LOCAL_WIFI_MESS".app_localized, title: "SUCCESSFULL_TEXT".app_localized, completion: {
                    SVProgressHUD.show()
                    self?.viewModel.waitingSensorsJoinNetwork(completion: {
                        SVProgressHUD.dismiss(completion: {
                            self?.startToDectectDevice()
                        })
                    })
                })
            } else {
                self?.viewModel.updateUI(with: .noDevice)
                self?.app_showInfoAlert("WIFI_SSID_OR_PASS_IS_INCORRECT_MESS".app_localized, title: "ERROR_TITLE".app_localized, completion: {
                    self?.viewModel.showWifiDetail()
                })
            }
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.viewModel.goAddHeaterFlow()
    }
    
    @IBAction func backAction(_ sender: Any) {
        if self.addedSuccessfullyView.isHidden == false {
            if isFromRoomConfiguration {
                backToViewControler(viewController: ConfigurationRoomViewController.self)
            } else {
                backToRoot()
            }
        } else {
            back()
        }
    }

     
}

extension SensorManagementViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


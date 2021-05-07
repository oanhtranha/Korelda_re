//
//  EditSensorViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class EditSensorViewController: BaseViewController, BaseControllerProtocol {

    @IBOutlet weak var sensorNameTextField: AndroidStyle3TextField!
    @IBOutlet weak var pairedWithHeatersLabel: UILabel!
    @IBOutlet weak var sensorModelLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var isOnCharge: UILabel!
    @IBOutlet weak var deleteSensorButton: UIButton!
    @IBOutlet weak var nPairedHeaterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var batteryTitleLabel: UILabel!
    @IBOutlet weak var temperatureTitleLabel: UILabel!
    @IBOutlet weak var humidityTitleLabel: UILabel!
    
    var viewModel: EditSensorViewModelProtocol!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func needUpdateSelectedRoom() {
        viewModel.needUpdateSelectedRoom()
    }
    
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateSelectedRoom),
                                               name: .KLDNeedUpdateSelectedRoom, object: nil)
        sensorNameTextField.isEnabled = false
        viewModel.sensorName.asObservable().bind(to: sensorNameTextField.rx.text).disposed(by: disposeBag)
        sensorNameTextField.rx.text.orEmpty.bind(to: viewModel.sensorName).disposed(by: disposeBag)
        viewModel.pairedWithHeaters.asObservable().bind(to: pairedWithHeatersLabel.rx.text).disposed(by: disposeBag)
        viewModel.nPairedHeaters.asObservable().bind { [weak self] (nHeaters) in
            self?.nPairedHeaterImageView.isHidden = nHeaters == 0
            self?.nPairedHeaterImageView.image = UIImage(named: nHeaters > 1 ? "ic-connected-heaters" : "ic-connected-heater")
        }
        viewModel.sensorModel.asObservable().bind(to: sensorModelLabel.rx.text).disposed(by: disposeBag)
        viewModel.temperature.asObservable().bind(to: temperatureLabel.rx.text).disposed(by: disposeBag)
        viewModel.humidity.asObservable().bind(to: humidityLabel.rx.text).disposed(by: disposeBag)
        viewModel.battery.asObservable().bind(to: batteryLabel.rx.text).disposed(by: disposeBag)
        deleteSensorButton.rx.tap.bind { [weak self] in
            self?.showPopupToDeleteSensor()
        }.disposed(by: disposeBag)
    }
    
    func showPopupToDeleteSensor() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickLetfButton = {
                self.showConfirmPopUp()
            }
            if let sensorName: String = viewModel.sensorName.value {
                vc.typeAlert = .deleteSensor(sensorName: sensorName)
            }
            showPopup(vc)
        }
        
        deleteSensorButton.setTitle("REMOVE_TEXT".app_localized, for: .normal)
        titleLabel.text = "EDIT_SENSOR_TEXT".app_localized
        sensorNameTextField.titleText = "SENSOR_NAME_TEXT".app_localized
        statusTitleLabel.text = "STATUS_TEXT".app_localized
        activeLabel.text = "ACTIVE_TEXT".app_localized
        batteryTitleLabel.text = "BATTERY_CHARGE_TEXT".app_localized
        temperatureTitleLabel.text = "TEMPERATURE_TEXT".app_localized
        humidityTitleLabel.text = "HUMIDITY_TEXT".app_localized
    }
    
    private func showConfirmPopUp() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickRightButton = {
                self.viewModel.deleteSensor(completion: { isSuccess in
                    SVProgressHUD.dismiss()
                    if isSuccess {
                        NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                        self.app_showInfoAlert("DELETED_SENSOR_SUCCESS_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                            self.viewModel.backToHome()
                        })
                    } else {
                        self.app_showInfoAlert("CAN_NOT_DELETE_SENSOR_MESS".app_localized)
                    }
                })
            }
            vc.typeAlert = .confirmDeleteSensor
            showPopup(vc)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
}

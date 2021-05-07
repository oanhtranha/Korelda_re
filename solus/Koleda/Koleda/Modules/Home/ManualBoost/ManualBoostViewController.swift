//
//  ManualBoostViewController.swift
//  Koleda
//
//  Created by Oanh tran on 8/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD


class ManualBoostViewController: BaseViewController, BaseControllerProtocol {

    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var currentTempratureLabel: UILabel!
    @IBOutlet weak var editingTempratureLabel: UILabel!
    @IBOutlet weak var editingTempraturesmallLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var countDownTimeLabel: UILabel!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decresseButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var adjustView: UIView!
    
    var viewModel: ManualBoostViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func needUpdateSelectedRoom() {
        viewModel.needUpdateSelectedRoom()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func changeVlaue(_ sender: UISlider) {
        viewModel.updateSettingTime(seconds: Int(sender.value))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        addCloseFunctionality()
        viewModel.setup()
    }
    
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateSelectedRoom),
                                               name: .KLDNeedUpdateSelectedRoom, object: nil)
        Style.Button.primary.apply(to: setButton)
        Style.Button.halfWithWhiteSmall.apply(to: cancelButton)
        Style.View.shadowBlackRemote.apply(to: adjustView)
        timeSlider.maximumValue = Float(Constants.MAX_END_TIME_POINT + 1)
        timeSlider.minimumValue = 0
        timeSlider.addTarget(self, action: #selector(changeVlaue(_:)), for: .valueChanged)

        viewModel.statusString.asObservable().bind { [weak self] status in
            self?.statusLabel.text = status
        }.disposed(by: disposeBag)
        
        increaseButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.adjustTemprature(increased: true)
        }.disposed(by: disposeBag)
        
        decresseButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.adjustTemprature(increased: false)
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.resetSettingTime(completion: { success, errorMessage in
                guard success else {
                    if errorMessage != "" {
                        self?.app_showInfoAlert(errorMessage)
                    }
                    return
                }
                self?.app_showInfoAlert("Reset Manual Boost Successfully!")
                NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            })
        }.disposed(by: disposeBag)
        
        setButton.rx.tap.bind { [weak self] _ in
            SVProgressHUD.show()
            self?.viewModel.manualBoostUpdate(completion: { [weak self] isSuccess in
                SVProgressHUD.dismiss()
                if isSuccess {
                    NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                    self?.app_showInfoAlert("Manual Boost updated Successfully!", title: "Koleda", completion: {
                        self?.dismiss(animated: true, completion: nil)
                    })
                } else {
                    self?.app_showInfoAlert("Manual Boost can't update now")
                }
            })
        }.disposed(by: disposeBag)
        
        viewModel.currentTemperature.asObservable().bind(to: currentTempratureLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.editingTemprature.asObservable().bind { [weak self] value in
            self?.editingTempratureLabel.text = "\(value)°" 
        }.disposed(by: disposeBag)
        
        viewModel.editingTempratureSmall.asObservable().bind { [weak self] value in
            self?.editingTempraturesmallLabel.text =  value > 0 ? "\(value)" : ""
        }.disposed(by: disposeBag)
        
        viewModel.countDownTime.asObservable().bind { [weak self] value in
            self?.countDownTimeLabel.text = value
        }.disposed(by: disposeBag)
        
        viewModel.endTime.asObservable().bind(to: endTimeLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.sliderValue.asObservable().bind { [weak self] value in
            self?.timeSlider.setValue(value, animated: true)
            self?.setButton.isEnabled = value > 0
        }.disposed(by: disposeBag)
        viewModel.manualBoostTimeout.asObservable().subscribe(onNext: { [weak self] in
            SVProgressHUD.show(withStatus: "Manual Boost Timeout")
            self?.viewModel.refreshRoom(completion: { success in
                SVProgressHUD.dismiss()
            })
        }).disposed(by: disposeBag)
    }
}

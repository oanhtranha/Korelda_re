//
//  WifiDetailViewController.swift
//  Koleda
//
//  Created by Oanh tran on 12/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class WifiDetailViewController: BaseViewController, BaseControllerProtocol {

	@IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var wifiSSIDTextField: AndroidStyleTextField!
    @IBOutlet weak var passwordTextField: AndroidStyleTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var viewModel: WifiDetailViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setTitleScreen(with: "")
        viewModel.setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showOrHidePass(_ sender: Any) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    private func configurationUI() {
		progressBarView.setupNav(viewController: self)
        Style.Button.primary.apply(to: saveButton)
        viewModel.ssidText.asObservable().bind(to: wifiSSIDTextField.rx.text).disposed(by: disposeBag)
        wifiSSIDTextField.rx.text.orEmpty.bind(to: viewModel.ssidText).disposed(by: disposeBag)
        viewModel.wifiPassText.asObservable().bind(to: passwordTextField.rx.text).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.wifiPassText).disposed(by: disposeBag)
        viewModel.ssidErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.wifiSSIDTextField.errorText = message
            if message.isEmpty {
                self?.wifiSSIDTextField.showError(false)
            } else {
                self?.wifiSSIDTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        saveButton.rx.tap.bind { [weak self] _ in
			self?.saveButton.isEnabled = false
			self?.viewModel.saveWifiInfo(completion: {
				self?.saveButton.isEnabled = true
			})
        }.disposed(by: disposeBag)
        viewModel.disableCloseButton.asObservable().subscribe(onNext: { [weak self] disable in
            self?.progressBarView.backButton.isEnabled = !disable
        }).disposed(by: disposeBag)
        titleLabel.text = "INPUT_YOUR_HOME_WIFI_MESS".app_localized
        wifiSSIDTextField.titleText = "WIFI SSID".app_localized
        passwordTextField.titleText = "PASSWORD_TITLE".app_localized
        saveButton.setTitle("SAVE_TEXT".app_localized, for: .normal)
    }
	
}

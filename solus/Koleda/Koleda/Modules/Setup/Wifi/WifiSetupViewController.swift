//
//  WifiSetupViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class WifiSetupViewController: BaseViewController, BaseControllerProtocol {

    @IBOutlet weak var wifiImageView: UIImageView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var buttomsStackView: UIStackView!
    @IBOutlet weak var checkingView: UIView!
    @IBOutlet weak var noConnectView: UIView!
    
    
    @IBOutlet weak var wifiConnectionLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var retryLabel: UILabel!
    @IBOutlet weak var skipAndContinueLabel: UILabel!
    
    var viewModel: WifiSetupViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.showRetryButton.asObservable().subscribe(onNext: { [weak self] show in
            self?.wifiImageView.image = UIImage(named: show ?  "ic-not-connected-wifi" : "ic-checking-wifi")
            self?.buttomsStackView.isHidden = !show
            self?.checkingView.isHidden = show
            self?.noConnectView.isHidden = !show
        }).disposed(by: disposeBag)
        retryButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.checkWifiConnection()
        }.disposed(by: disposeBag)
        skipButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.showWifiDetailScreen()
        }.disposed(by: disposeBag)
        viewModel.disableCloseButton.asObservable().subscribe(onNext: { [weak self] disable in
            self?.closeButton?.isEnabled = !disable
        }).disposed(by: disposeBag)
        wifiConnectionLabel.text = "WIFI_CONNECTION_TEXT".app_localized
        loadingLabel.text = "CHECKING_WIFI_CONNECTION_MESS".app_localized
        retryLabel.text = "RETRY_TEXT".app_localized
        skipAndContinueLabel.text = "SKIP_AND_CONTINUE_TEXT".app_localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        setTitleScreen(with: "")
        statusBarStyle(with: .lightContent)
    }
    
    @IBAction func backAction(_ sender: Any) {
        closeCurrentScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         viewModel.checkWifiConnection()
    }

}

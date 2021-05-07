//
//  LocationSetupViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import Network

class LocationSetupViewController: BaseViewController, BaseControllerProtocol {
    
    var viewModel: LocationSetupViewModelProtocol!
    @IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var allowLabel: UILabel!
    @IBOutlet weak var declineLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.declineLocationService()
        }.disposed(by: disposeBag)
        
        yesButton.rx.tap.bind { [weak self] _ in
            self?.yesButton.isEnabled = false
            self?.viewModel.requestAccessLocationService {
                self?.yesButton.isEnabled = true
            }
        }.disposed(by: disposeBag)
        
        viewModel.showLocationDisabledPopUp.asObservable().subscribe(onNext: { [weak self] show in
            if show {
                self?.showLocationDisabledPopUp()
            }
        }).disposed(by: disposeBag)
		progressBarView.setupNav(viewController: self)
        titleLabel.text = "ALLOW_SOLUS_USE_YOUR_GEOLOCATION_MESS".app_localized
        descriptionLabel.text = "THIS_IS_NECESSARY_FOR_THE_CORRECT_DETECTION_OF_YOUR_LOCATION_MESS".app_localized
        allowLabel.text = "ALLOW_TEXT".app_localized
        declineLabel.text = "DECLINE_TEXT".app_localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        setTitleScreen(with: "")
    }
    
    private func showLocationDisabledPopUp() {
        app_showPromptAlert(title: "ALLOW_ACCESS_LOCATION_IN_SETTING_TITLE".app_localized,
                            message: "ALLOW_ACCESS_LOCATION_IN_SETTING_MESSAGE".app_localized,
                            acceptTitle: "OPEN_SETTINGS_TITLE".app_localized,
                            dismissTitle: "CANCEL".app_localized,
                            acceptCompletion: {
                                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
        }, dismissCompletion: nil)
    }
}

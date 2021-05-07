//
//  ProgressBarView.swift
//  Koleda
//
//  Created by Oanh Tran on 7/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class ProgressBarView: UIView {

	
	@IBOutlet weak var backImageView: UIImageView!
	@IBOutlet weak var stepLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var progressView: UIProgressView!
	
    private let disposeBag = DisposeBag()
	override func awakeFromNib() {
		super.awakeFromNib()
		kld_loadContentFromNib()
	}
    
    func setupNav(viewController: BaseViewController) {
        backButton.rx.tap.bind {
            viewController.closeCurrentScreen()
        }.disposed(by: disposeBag)
        if UserDefaultsManager.loggedIn.enabled || UserDataManager.shared.stepProgressBar.totalStep == 0 {
            stepLabel.isHidden = true
            progressView.isHidden = true
        } else {
            stepLabel.isHidden = false
            progressView.isHidden = false
            loadStep(viewController: viewController)
        }
    }
    
    func loadStep(viewController: BaseViewController) {
        let stepProgressBar = UserDataManager.shared.stepProgressBar
        let currentStep = stepProgressBar.currentStep + 1
        UserDataManager.shared.stepProgressBar.currentStep = currentStep
        let stepString = "STEP_TEXT".app_localized
        self.stepLabel.text = String(format: "%@ %d", stepString, currentStep)
        let value = Float(currentStep)/Float(stepProgressBar.totalStep)
        self.progressView.setProgress(value, animated: true)
    }
	
}

//
//  TemperatureUnitViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class TemperatureUnitViewController: BaseViewController, BaseControllerProtocol {

	@IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var cUnitTempView: TemperatureUnitView!
    @IBOutlet weak var fUnitTempView: TemperatureUnitView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cesiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    var viewModel: TemperatureUnitViewModelProtocol!
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
        viewModel.viewWillAppear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
    private func configurationUI() {
        Style.View.shadowCornerWhite.apply(to: cUnitTempView)
        Style.View.shadowCornerWhite.apply(to: fUnitTempView)
        cUnitTempView.setUp(unit: .C)
        fUnitTempView.setUp(unit: .F)
        viewModel.seletedUnit.asObservable().subscribe(onNext: { [weak self] unit in
            self?.cUnitTempView.updateStatus(enable: unit == .C)
            self?.fUnitTempView.updateStatus(enable: unit == .F)
        }).disposed(by: disposeBag)
        viewModel.hasChanged.asObservable().subscribe(onNext: { [weak self] changed in
            if !changed {
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_UPDATE_TEMPERATURE_UNIT_MESS".app_localized)
            }
        }).disposed(by: disposeBag)
        confirmButton.rx.tap.bind { [weak self]  in
            guard let `self` = self else {
                return
            }
            self.viewModel.confirmedAndFinished()
        }.disposed(by: disposeBag)
        
        cesiusButton.rx.tap.bind {
            self.viewModel.updateUnit(selectedUnit: .C)
        }.disposed(by: disposeBag)
        
        fahrenheitButton.rx.tap.bind {
            self.viewModel.updateUnit(selectedUnit: .F)
        }.disposed(by: disposeBag)
		progressBarView.setupNav(viewController: self)
        //
        temperatureLabel.text = "TEMPERATURE_TEXT".app_localized
        descriptionLabel.text = "AND_FINALLY_HOW_WOULD_YOU_MEASURE_TEMP_MESS".app_localized
        confirmLabel.text = "CONFIRM_AND_FINISH".app_localized
	}
	
}

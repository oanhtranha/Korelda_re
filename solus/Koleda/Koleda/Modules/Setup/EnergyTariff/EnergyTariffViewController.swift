//
//  EnergyTariffViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class EnergyTariffViewController: BaseViewController, BaseControllerProtocol, KeyboardAvoidable {
	@IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var daytimeView: UIView!
    @IBOutlet weak var nighttimeView: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var amountPerHourDayLabel: UILabel!
    @IBOutlet weak var currencyUnitDayLabel: UILabel!
    
    @IBOutlet weak var dayStartTimeLabel: UILabel!
    @IBOutlet weak var dayEndTimeLabel: UILabel!
    
    @IBOutlet weak var amountPerHourNightLabel: UILabel!
    @IBOutlet weak var currencyUnitNightLabel: UILabel!
    @IBOutlet weak var nightStartTimeLabel: UILabel!
    @IBOutlet weak var nightEndTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var daytimeTariffLabel: UILabel!
    @IBOutlet weak var dayDescriptionLabel: UILabel!
    @IBOutlet weak var dayStartLabel: UILabel!
    @IBOutlet weak var dayEndLabel: UILabel!
    @IBOutlet weak var nightTimeTariffLabel: UILabel!
    @IBOutlet weak var nightDescriptionLabel: UILabel!
    @IBOutlet weak var nightStartLabel: UILabel!
    @IBOutlet weak var nightEndLabel: UILabel!
    @IBOutlet weak var skipAndContinueLabel: UILabel!
    
    var viewModel: EnergyTariffViewModelProtocol!
    private let disposeBag = DisposeBag()
    private var currentEditingPoint: TimePoint!
    private var currentEditingTime: String = ""
    var keybroadHelper: KeyboardHepler!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
        keybroadHelper = KeyboardHepler(scrollView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.top
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        setTitleScreen(with: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TimePickerViewController.get_identifier, let timePickerVC = segue.destination as? TimePickerViewController {
            timePickerVC.delegate = self
            timePickerVC.initTimePicker(timePoint: currentEditingPoint, time: currentEditingTime)
        }
    }
    
    @IBAction func amountPerHourDayAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .amountPerHourDay
            vc?.amountPerHour = Double(amountPerHourDayLabel.text ?? "0.0") ?? 0
            vc?.currencyUnit = currencyUnitDayLabel.text!
            vc?.delegate = self
        }
    }
    
    @IBAction func amountPerHourNightAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .amountPerHourNight
            vc?.amountPerHour = Double(amountPerHourNightLabel.text ?? "0.0") ?? 0
            vc?.currencyUnit = currencyUnitNightLabel.text!
            vc?.delegate = self
        }
    }
	
    @IBAction func dayStartTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .dayStartTime
            vc?.delegate = self
            if let startTime = dayStartTimeLabel.text, !startTime.isEmpty {
                vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            }
            if let endTime = dayEndTimeLabel.text, !endTime.isEmpty {
                vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            }
        }
    }
    @IBAction func dayEndTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .dayEndTime
            vc?.delegate = self
            if let startTime = dayStartTimeLabel.text, !startTime.isEmpty {
                vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            }
            if let endTime = dayEndTimeLabel.text, !endTime.isEmpty {
                vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            }
        }
    }
    
    @IBAction func nightStartTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .nightStartTime
            vc?.delegate = self
            if let startTime = nightStartTimeLabel.text, !startTime.isEmpty {
                vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            }
            if let endTime = nightEndTimeLabel.text, !endTime.isEmpty {
                vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            }
        }
    }
    @IBAction func nightEndTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .nightEndTime
            vc?.delegate = self
            if let startTime = nightStartTimeLabel.text, !startTime.isEmpty {
                vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            }
            if let endTime = nightEndTimeLabel.text, !endTime.isEmpty {
                vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            }
        }
    }
}

extension EnergyTariffViewController {
    private func configurationUI() {
		Style.Button.primary.apply(to: nextButton)
        nextButton.rx.tap.bind { [weak self] _ in
            SVProgressHUD.show()
            self?.viewModel.next {
                SVProgressHUD.dismiss()
            }
        }.disposed(by: disposeBag)
        skipButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.showNextScreen()
        }.disposed(by: disposeBag)
        viewModel.tariffOfDay.asObservable().bind(to: amountPerHourDayLabel.rx.text).disposed(by: disposeBag)
        viewModel.startOfDay.asObservable().bind(to: dayStartTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.endOfDay.asObservable().bind(to: dayEndTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.tariffOfNight.asObservable().bind(to: amountPerHourNightLabel.rx.text).disposed(by: disposeBag)
        viewModel.startOfNight.asObservable().bind(to: nightStartTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.endOfNight.asObservable().bind(to: nightEndTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.currency.asObservable().bind(to: currencyUnitDayLabel.rx.text).disposed(by: disposeBag)
        viewModel.currency.asObservable().bind(to: currencyUnitNightLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.errorMessage.asObservable().subscribe(onNext: { [weak self]  message in
            if message != "" {
                self?.app_showInfoAlert(message)
            }
        }).disposed(by: disposeBag)
        
        viewModel.updateFinished.asObservable().subscribe(onNext: { [weak self] isSuccess in
            if isSuccess {
                self?.app_showInfoAlert("UPDATED_TARIFF_INFO_SUCCESS_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                    self?.viewModel.showNextScreen()
                })
            } else {
                self?.app_showInfoAlert("UPDATED_TARIFF_INFO_FAILED_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: nil)
            }
            
        }).disposed(by: disposeBag)
		progressBarView.setupNav(viewController: self)
        titleLabel.text = "SETUP_YOUR_ENERGY_TARIFF".app_localized
        daytimeTariffLabel.text = "DAYTIME_TARIFF_TEXT".app_localized
        dayDescriptionLabel.text = "INPUT_DAYTIME_TARIFF_MESS".app_localized
        dayStartLabel.text = "START_TEXT".app_localized
        dayEndLabel.text = "END_TEXT".app_localized
        nightTimeTariffLabel.text = "NIGHTTIME_TARIFF_TEXT".app_localized
        nightDescriptionLabel.text = "INPUT_NIGHTTIME_TARIFF_MESS".app_localized
        nightStartLabel.text = "START_TEXT".app_localized
        nightEndLabel.text = "END_TEXT".app_localized
        skipAndContinueLabel.text = "SKIP_AND_CONTINUE_TEXT".app_localized
        nextButton.setTitle("CONFIRM_TEXT".app_localized, for: .normal)
    }
    
    @objc private func tapDone() {
        self.view.endEditing(true)
    }
    
    private func validate(point: TimePoint, time: Time) -> (Bool,String) {
        switch point {
        case .startOfDay:
            guard let endOfDayTime = dayEndTimeLabel.text?.timeValue() else {
                return (true, "")
            }
            if time.hour*60 + time.minute == endOfDayTime.hour*60 + endOfDayTime.minute {
                return (false, "START_DAYTIME_TARIFF_MUST_DIFFERENT_END_DAYTIME_TARIFF".app_localized)
            }
        case .endOfDay:
            guard let startOfDayTime = dayStartTimeLabel.text?.timeValue() else {
                return (true, "")
            }
            if time.hour*60 + time.minute == startOfDayTime.hour*60 + startOfDayTime.minute {
                return (false, "END_DAYTIME_TARIFF_MUST_DIFFERENT_START_DAYTIME_TARIFF".app_localized)
            }
        case .startOfNight:
            guard let endOfNightTime = nightEndTimeLabel.text?.timeValue() else {
                return (true, "")
            }
            if time.hour*60 + time.minute == endOfNightTime.hour*60 + endOfNightTime.minute {
                return (false, "START_NIGHTTIME_TARIFF_MUST_DIFFERENT_END_NIGHTTIME_TARIFF".app_localized)
            }
        case .endOfNight:
            guard let startOfNightTime = nightStartTimeLabel.text?.timeValue() else {
                return (true, "")
            }
            if time.hour*60 + time.minute == startOfNightTime.hour*60 + startOfNightTime.minute {
                return (false, "END_NIGHTTIME_TARIFF_MUST_DIFFERENT_START_NIGHTTIME_TARIFF".app_localized)
            }
        }
        return (true, "")
    }
    
}

extension EnergyTariffViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       
        switch textField {
        case dayStartTimeLabel:
            currentEditingPoint = .startOfDay
        case dayEndTimeLabel:
            currentEditingPoint = .endOfDay
        case nightStartTimeLabel:
            currentEditingPoint = .startOfNight
        case nightEndTimeLabel:
            currentEditingPoint = .endOfNight
        default:
            return true
        }
        currentEditingTime = textField.text?.extraWhitespacesRemoved ?? ""
        performSegue(withIdentifier: TimePickerViewController.get_identifier, sender: self)
        return false
    }
}

extension EnergyTariffViewController: TimePickerViewControllerDelegate {
    func selectedTime(time: Time) {
        self.dismiss(animated: true) {
            guard let timePoint =  self.currentEditingPoint else {
                return
            }
            let validateResult = self.validate(point: timePoint, time: time)
            if validateResult.0 {
                self.updateTimes(with: time, point: timePoint, completion: {
                    self.viewModel.startOfDay.value = self.dayStartTimeLabel.text ?? ""
                    self.viewModel.endOfDay.value = self.dayEndTimeLabel.text ?? ""
                    self.viewModel.startOfNight.value = self.nightStartTimeLabel.text ?? ""
                    self.viewModel.endOfNight.value = self.nightEndTimeLabel.text ?? ""
                })
            } else {
                self.app_showInfoAlert(validateResult.1, title: "ERROR_TITLE".app_localized, completion: {
                    self.performSegue(withIdentifier: TimePickerViewController.get_identifier, sender: self)
                })
            }
        }
    }
    
    private func updateTimes(with editingTime: Time, point: TimePoint, completion: @escaping () -> Void) {
        let timeString = editingTime.timeString()
        switch point {
        case .startOfDay:
            self.dayStartTimeLabel.text = timeString
            guard let endOfDaytime = self.dayEndTimeLabel.text?.timeValue() else {
                completion()
                return
            }
            refillOtherTimes(isDaytime: true, start: editingTime, end: endOfDaytime)
        case .endOfDay:
            self.dayEndTimeLabel.text = timeString
            guard let startOfDaytime = self.dayStartTimeLabel.text?.timeValue() else {
                completion()
                return
            }
            refillOtherTimes(isDaytime: true, start: startOfDaytime, end: editingTime)
        case .startOfNight:
            self.nightStartTimeLabel.text = timeString
            guard let endOfNighttime = self.nightEndTimeLabel.text?.timeValue() else {
                completion()
                return
            }
            refillOtherTimes(isDaytime: false, start: editingTime, end: endOfNighttime)
        case .endOfNight:
            self.nightEndTimeLabel.text = timeString
            guard let startOfNighttime = self.nightStartTimeLabel.text?.timeValue() else {
                completion()
                return
            }
            refillOtherTimes(isDaytime: false, start: startOfNighttime, end: editingTime)
        }
        completion()
    }

    private func refillOtherTimes(isDaytime: Bool, start: Time, end: Time) {
        if isDaytime {
            nightStartTimeLabel.text = end.timeString()
            nightEndTimeLabel.text = start.timeString()
        } else {
            dayStartTimeLabel.text = end.timeString()
            dayEndTimeLabel.text = start.timeString()
        }
    }
    
}

extension EnergyTariffViewController: EnergyTariffInputDelegate {
    func selectedAmountPerHour(isDay: Bool, amount: Double, currencyUnit: String) {
        if isDay {
            viewModel.updatetTariffOfDay(amount: amount.toString(fractionDigits: 2))
        } else {
            viewModel.updatetTariffOfNight(amount: amount.toString(fractionDigits: 2))
        }
        currencyUnitDayLabel.text = currencyUnit
        currencyUnitNightLabel.text = currencyUnit
        viewModel.currency.value = currencyUnit
    }
    
    func selectedTime(isDay: Bool, startTime: String, endTime: String) {
        if isDay == true {
            viewModel.startOfDay.value = startTime
            viewModel.endOfDay.value = endTime
            viewModel.startOfNight.value = endTime
            viewModel.endOfNight.value = startTime
        } else {
            viewModel.startOfDay.value = endTime
            viewModel.endOfDay.value = startTime
            viewModel.startOfNight.value = startTime
            viewModel.endOfNight.value = endTime
        }
    }
    
    
}

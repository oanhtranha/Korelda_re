//
//  MenuSettingsViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import MessageUI
import Segmentio
import SVProgressHUD

class MenuSettingsViewController: BaseViewController, BaseControllerProtocol {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleAmountLabel: UILabel!
    @IBOutlet weak var costMonteringSegment: Segmentio!
    @IBOutlet weak var TempUnitLabel: UILabel!
    @IBOutlet weak var celsiusToogleImageView: UIImageView!
    @IBOutlet weak var celsiusToogleButton: UIButton!
    @IBOutlet weak var settingItemsTableView: UITableView!
    @IBOutlet weak var reportBugsButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appSettingsLabel: UILabel!
    @IBOutlet weak var temperatureUnitLabel: UILabel!
    
    var viewModel: MenuSettingsViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationBarTransparency()
        addCloseFunctionality(.white)
        addLogoutButton()
        statusBarStyle(with: .lightContent)
        viewModel.viewWillAppear()
    }

    @IBAction func celsiusButtonAction(_ sender: Any) {
        SVProgressHUD.show()
        celsiusToogleButton.isEnabled = false
        viewModel.updateTempUnit {
            SVProgressHUD.dismiss()
            self.celsiusToogleButton.isEnabled = true
        }
    }
    
    private func configurationUI() {
        configCostMontoringSegment()
        Style.Button.primary.apply(to: reportBugsButton)
        userImageView.layer.cornerRadius = userImageView.frame.width / 2.0
        userImageView.layer.masksToBounds = true
        viewModel?.profileImage.drive(userImageView.rx.image).disposed(by: disposeBag)
        Style.View.shadowCornerWhite.apply(to: amountView)
        viewModel.settingItems.asObservable().bind { [weak self] modeItems in
            self?.settingItemsTableView.reloadData()
        }.disposed(by: disposeBag)
        
        viewModel.userName.asObservable().bind { [weak self] value in
            self?.userNameLabel.text = value
        }.disposed(by: disposeBag)
        
        viewModel.email.asObservable().bind { [weak self] value in
            self?.emailLabel.text = value
        }.disposed(by: disposeBag)
        
        viewModel.energyConsumed.asObservable().bind { [weak self] value in
            self?.amountLabel.text = value
        }.disposed(by: disposeBag)
        
        viewModel.timeTitle.asObservable().bind { [weak self] value in
            self?.titleAmountLabel.text = value
        }.disposed(by: disposeBag)
        
        viewModel.currentTempUnit.asObservable().bind { [weak self] unit in
            self?.celsiusToogleImageView.image = unit == .C ? UIImage(named: "ic-switch-on") : UIImage(named: "ic-switch-off")
            self?.TempUnitLabel.text = unit == .C ? "CELSIUS_TEXT".app_localized.uppercased() : "FAHRENHEIT_TEXT".app_localized.uppercased()
        }.disposed(by: disposeBag)
        
        viewModel.needUpdateAfterTempUnitChanged.asObservable().subscribe(onNext: { [weak self] changed in
            if changed {
                NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            } else {
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_UPDATE_TEMPERATURE_UNIT_MESS".app_localized)
            }
        }).disposed(by: disposeBag)
        
        viewModel.leaveHomeSubject.asObservable().subscribe(onNext: { [weak self] in
            SVProgressHUD.show()
            self?.viewModel.leaveHome(completion: { success in
                SVProgressHUD.dismiss()
                if success {
                    self?.viewModel.logOut()
                } else {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_LEAVE_MASTER_MESS".app_localized)
                }
                
            })
        }).disposed(by: disposeBag)
        
        reportBugsButton.rx.tap.bind {  [weak self] in
            self?.sendEmail()
        }.disposed(by: disposeBag)
        appSettingsLabel.text = "APP_SETTINGS_TEXT".app_localized
        temperatureUnitLabel.text = "TEMPERATURE_UNITS_TEXT".app_localized
        reportBugsButton.setTitle("REPORT_BUGS_AND_PROBLEMS".app_localized, for: .normal)
    }
    
    private func configCostMontoringSegment() {
        let content: [SegmentioItem] =  [SegmentioItem(title: "MONTH_TEXT".app_localized, image: nil), SegmentioItem(title: "WEEK_TEXT".app_localized, image: nil), SegmentioItem(title: "DAY_TEXT".app_localized, image: nil)]

        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.SFProDisplayRegular(ofSize: 16),
                titleTextColor: .gray
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.SFProDisplayRegular(ofSize: 16),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.SFProDisplayRegular(ofSize: 16),
                titleTextColor: .black
            )
        )
        
        let indicatorOptions = SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 2,
            color: .orange
        )
        
        let horizontalSeparatorOptions = SegmentioHorizontalSeparatorOptions(
            type: SegmentioHorizontalSeparatorType.bottom, // Top, Bottom, TopAndBottom
            height: 1,
            color: UIColor.lightLine
        )
        let options = SegmentioOptions(backgroundColor: .clear, segmentPosition: SegmentioPosition.dynamic, scrollEnabled: false, indicatorOptions: indicatorOptions, horizontalSeparatorOptions: horizontalSeparatorOptions, verticalSeparatorOptions: nil, imageContentMode: UIView.ContentMode.center, labelTextAlignment: .center, labelTextNumberOfLines: 1, segmentStates: states, animationDuration: 0)
        
        costMonteringSegment.setup(content: content, style: SegmentioStyle.onlyLabel, options: options)
        
        costMonteringSegment.selectedSegmentioIndex = 0
        costMonteringSegment.valueDidChange = {  [weak self] segmentio, segmentIndex in
            self?.viewModel.showEneryConsume(of: ConsumeType.init(from: segmentIndex))
        }
    }
    
    override func logout() {
        viewModel.logOut()
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([AppConstants.supportEmail])
            mail.setSubject("REPORT_BUGS_AND_PROBLEMS".app_localized)
            present(mail, animated: true, completion: nil)
        } else if let emailUrl = createEmailUrl(to: AppConstants.supportEmail, subject: "", body: "") {
            UIApplication.shared.open(emailUrl)
            // show failure alert
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
}

extension MenuSettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension MenuSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.settingItems.value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingItemtableViewCell.get_identifier, for: indexPath) as? SettingItemtableViewCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let menuItem = self.viewModel.settingItems.value[indexPath.row]
        cell.setup(menuItem: menuItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedItem(at: indexPath.row)
    }
}


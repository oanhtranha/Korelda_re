//
//  InviteFriendsDetailViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class InviteFriendsDetailViewController: BaseViewController, BaseControllerProtocol {

	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var emailTextField: AndroidStyleTextField!
    
    @IBOutlet weak var emailsTableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
	var viewModel: InviteFriendsDetailViewControllerProtocol!
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
    
	private func configurationUI() {
        emailsTableView.dataSource = self
        emailsTableView.delegate = self
		Style.Button.primary.apply(to: continueButton)
        
        viewModel.emailText.asObservable().bind(to: emailTextField.rx.text).disposed(by: disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.emailText).disposed(by: disposeBag)
        
        inviteButton.rx.tap.bind { [weak self] in
            SVProgressHUD.show()
            self?.inviteButton.isEnabled = false
            self?.viewModel.invitedAFriend(completion: { success, error in
                SVProgressHUD.dismiss()
                self?.inviteButton.isEnabled = true
                if success {
                    self?.emailTextField.text = ""
                } else if let error = error {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: error.localizedDescription)
                }
            })
        }.disposed(by: disposeBag)
        continueButton.isHidden = UserDefaultsManager.loggedIn.enabled
		continueButton.rx.tap.bind { [weak self] in
			self?.viewModel.showInviteFriendsFinished()
		}.disposed(by: disposeBag)
        
		backButton.rx.tap.bind { [weak self] in
			self?.closeCurrentScreen()
		}.disposed(by: disposeBag)
        
        viewModel.fiendsEmailList.asObservable().subscribe(onNext: { [weak self] _ in
            self?.emailsTableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.emailErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.emailTextField.errorText = message
            if message.isEmpty {
                self?.emailTextField.showError(false)
            } else {
                self?.emailTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        viewModel.showErrorMessage.asObservable().subscribe(onNext: { [weak self] errorMessage in
            self?.app_showAlertMessage(title: "KOLEDA_TEXT", message: errorMessage)
        }).disposed(by: disposeBag)
        titleLabel.text = "SHARE_THE_WARMTH_TEXT".app_localized
        descriptionLabel.text = "INVITE_FRIENDS_AND_FAMILY_MESS".app_localized
        inviteButton.setTitle("INVITE_TEXT".app_localized, for: .normal)
        emailTextField.titleText = "EMAIL_TITLE".app_localized
	}
}

extension InviteFriendsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.fiendsEmailList.value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emails = self.viewModel.fiendsEmailList.value
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.get_identifier, for: indexPath) as? FriendTableViewCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        cell.loadData(email: emails[indexPath.row])
        cell.removeButtonHandler = { [weak self] email in
            SVProgressHUD.show()
            self?.viewModel.removeFriendBy(email: email, completion: {
                SVProgressHUD.dismiss()
            })
        }
        return cell
    }
}

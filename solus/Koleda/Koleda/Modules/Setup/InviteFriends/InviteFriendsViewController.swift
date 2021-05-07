//
//  InviteFriendsViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class InviteFriendsViewController: BaseViewController, BaseControllerProtocol {

	var viewModel: InviteFriendViewModelProtocol!
	private let disposeBag = DisposeBag()
	
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var inviteButton: UIButton!
	@IBOutlet weak var skipButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		configurationUI()
		
    }
	
	@IBAction func backButton(_ sender: Any) {
		closeCurrentScreen()
	}
	
	private func configurationUI() {
        statusBarStyle(with: .lightContent)
		Style.Button.primary.apply(to: inviteButton)
		skipButton.rx.tap.bind { [weak self] in
		    self?.viewModel.showHomeScreen()
		}.disposed(by: disposeBag)
		
		inviteButton.rx.tap.bind { [weak self] in
			self?.viewModel.inviteFriends()
		}.disposed(by: disposeBag)

		backButton.rx.tap.bind {  [weak self] in
			self?.closeCurrentScreen()
		}.disposed(by: disposeBag)
        
        titleLabel.text = "CONGRATULATIONS_TEXT".app_localized
        messageLabel.text = "YOU_JUST_CREATED_HOME_MESS".app_localized
        inviteButton.setTitle("INVITE_FRIENDS_TEXT".app_localized, for: .normal)
        skipButton.setTitle("SKIP_TEXT".app_localized, for: .normal)
	}

}

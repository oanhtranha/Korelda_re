//
//  InviteFriendsFinishedViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class InviteFriendsFinishedViewController: BaseViewController, BaseControllerProtocol {
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var gotItButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	
	var viewModel: InviteFriendsFinishedViewModelProtocol!
	private let disposeBag = DisposeBag()
	
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		configurationUI()
    }

	private func configurationUI() {
        statusBarStyle(with: .lightContent)
		Style.Button.primary.apply(to: gotItButton)
		gotItButton.rx.tap.bind { [weak self] in
			self?.viewModel.showHomeScreen()
		}.disposed(by: disposeBag)
		backButton.rx.tap.bind { [weak self] in
			self?.viewModel.addMoreFriends()
		}
        titleLabel.text = "YOUR_INVITES_HAVE_BEEN_SENT_MESS".app_localized
        descriptionLabel.text = "YOUR_FRIENDS_AND_FAMILY_WILL_BE_ABLE_CONTROL_YOUR_HOUSE_MESS".app_localized
        gotItButton.setTitle("NEXT_TEXT".app_localized, for: .normal)
	}
}

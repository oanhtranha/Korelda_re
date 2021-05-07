//
//  CreateHomeViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 6/16/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD
import SwiftRichString

class CreateHomeViewController: BaseViewController, BaseControllerProtocol {
	
	@IBOutlet weak var progressBarView: ProgressBarView!
	@IBOutlet weak var welcomeView: UIView!
	@IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var letsStartButton: UIButton!
    
	@IBOutlet weak var homeTitleLabel: UILabel!
	@IBOutlet weak var homeNameTextField: AndroidStyleTextField!
	@IBOutlet weak var saveButton: UIButton!
	
	var viewModel: CreateHomeViewModelProtocol!
	private let disposeBag = DisposeBag()
	
    override func viewDidLoad() {
		super.viewDidLoad()
		configurationUI()
    }
	
	private func configurationUI() {
		progressBarView.setupNav(viewController: self)
		statusBarStyle(with: .lightContent)
		Style.Button.primary.apply(to: saveButton)
		Style.Button.primary.apply(to: letsStartButton)
		letsStartButton.rx.tap.bind { [weak self] in
			self?.welcomeView.isHidden = true
			self?.statusBarStyle(with: .default)
		}.disposed(by: disposeBag)
		saveButton.rx.tap.bind { [weak self] in
			self?.saveButton.isEnabled = false
			SVProgressHUD.show()
			self?.viewModel.saveAction {
				SVProgressHUD.dismiss()
				self?.saveButton.isEnabled = true
			}
		}.disposed(by: disposeBag)
		homeNameTextField.rx.text.orEmpty.bind(to: viewModel.homeName).disposed(by: disposeBag)
		viewModel.homeNameErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
			self?.homeNameTextField.errorText = message
			if message.isEmpty {
				self?.homeNameTextField.showError(false)
			} else {
				self?.homeNameTextField.showError(true)
			}
		}).disposed(by: disposeBag)
		
		viewModel.welcomeMessage.asObservable().bind { [weak self] title in
			let normal = SwiftRichString.Style{
				$0.font = UIFont.app_FuturaPTMedium(ofSize: 30)
				$0.color = UIColor.black
			}
			
			let bold = SwiftRichString.Style {
				$0.font = UIFont.app_FuturaPTMedium(ofSize: 30)
				$0.color = UIColor.orange
			}
			
			let group = StyleGroup(base: normal, ["h1": bold])
			self?.welcomeMessageLabel?.attributedText = title.set(style: group)
		}.disposed(by: disposeBag)
		
        welcomeMessageLabel.text = "WELCOME_HOME_MESS".app_localized
        descriptionLabel.text = "SETUP_YOUR_FIRST_HOME_WITH_SOLUS".app_localized
        letsStartButton.setTitle("LETS_START_TEXT".app_localized, for: .normal)
        
        
		let normal = SwiftRichString.Style{
			$0.font = UIFont.app_FuturaPTMedium(ofSize: 22)
			$0.color = UIColor.black
		}
		let bold = SwiftRichString.Style {
			$0.font = UIFont.app_FuturaPTMedium(ofSize: 22)
			$0.color = UIColor.orange
		}
		let groupHomeTitle = StyleGroup(base: normal, ["h1": bold])
        let string = "NAME_YOUR_HOME".app_localized
		homeTitleLabel.attributedText = string.set(style: groupHomeTitle)
        homeNameTextField.titleText = "NAME_TEXT".app_localized
        saveButton.setTitle("NEXT_TEXT".app_localized, for: .normal)
	}
}

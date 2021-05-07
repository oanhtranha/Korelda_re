//
//  ForgotPasswordViewController.swift
//  Koleda
//
//  Created by Oanh tran on 6/20/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class ForgotPasswordViewController: BaseViewController, BaseControllerProtocol, KeyboardAvoidable {
    
    var viewModel: ForgotPassWordViewModelProtocol!
    
    @IBOutlet weak var emailTextField: AndroidStyle2TextField!
    @IBOutlet weak var confirmEmailImageView: UIImageView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sendLinkLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    var keyboardHelper: KeyboardHepler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
        keyboardHelper = KeyboardHepler(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        statusBarStyle(with: .lightContent)
        self.edgesForExtendedLayout = UIRectEdge.top
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
    @IBAction func sendLinkAction(_ sender: UIButton) {
        sender.isEnabled = false
        SVProgressHUD.show()
        self.viewModel.getNewPassword(completion: { [weak self] (success, errorMessage) in
            sender.isEnabled = true
            SVProgressHUD.dismiss()
            if success {
                self?.app_showInfoAlert("RESET_PASS_SUCCESS_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                    self?.viewModel.router.dismiss(animated: true, context: nil, completion: nil)
                })
            } else if !errorMessage.isEmpty {
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: errorMessage)
            }
        })
    }
    
}

extension ForgotPasswordViewController {
    func configurationUI() {
        viewModel.email.asObservable().bind(to: emailTextField.rx.text).disposed(by: disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        
        viewModel.email.asObservable().subscribe(onNext: { [weak self]  value in
            self?.confirmEmailImageView.isHidden = isEmpty(value)
        }).disposed(by: disposeBag)
        
        viewModel.emailErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.emailTextField.errorText = message
            if message.isEmpty {
                self?.emailTextField.showError(false)
            } else {
                self?.emailTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        
        passwordLabel.text = "RESET_PASSWORD_TEXT".app_localized
        descriptionLabel.text = "PLEASE_ENTER_YOUR_EMAIL_FOR_RESET_PASS_MESS".app_localized
        emailTextField.titleText = "EMAIL_TITLE".app_localized
        emailTextField.placeholder = "ENTER_EMAIL_HERE_TEXT".app_localized
        sendLinkLabel.text = "SEND_LINK_TEXT".app_localized
        
    }
}

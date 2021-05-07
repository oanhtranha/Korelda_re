//
//  SignUpViewController.swift
//  Koleda
//
//  Created by Oanh tran on 5/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class SignUpViewController: BaseViewController, BaseControllerProtocol, KeyboardAvoidable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: AndroidStyle2TextField!
    @IBOutlet weak var emailTextField: AndroidStyle2TextField!
    @IBOutlet weak var passwordTextField: AndroidStyle2TextField!
    @IBOutlet weak var confirmFullNameImageView: UIImageView!
    @IBOutlet weak var confirmEmailImageView: UIImageView!
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    
    
    var keyboardHelper: KeyboardHepler?
    var viewModel: SignUpViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        statusBarStyle(with: .lightContent)
        self.edgesForExtendedLayout = UIRectEdge.top
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    func initView() {
        keyboardHelper = KeyboardHepler(scrollView)
        
        viewModel.fullName.asObservable().bind(to: nameTextField.rx.text).disposed(by: disposeBag)
        nameTextField.rx.text.orEmpty.bind(to: viewModel.fullName).disposed(by: disposeBag)
        viewModel.email.asObservable().bind(to: emailTextField.rx.text).disposed(by: disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        viewModel.password.asObservable().bind(to: passwordTextField.rx.text).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        viewModel.showPassword.asObservable().subscribe(onNext: { [weak self]  value in
            self?.passwordTextField.isSecureTextEntry = !value
        }).disposed(by: disposeBag)
        viewModel.fullName.asObservable().subscribe(onNext: { [weak self]  value in
            self?.confirmFullNameImageView.isHidden = isEmpty(value)
        }).disposed(by: disposeBag)
        viewModel.email.asObservable().subscribe(onNext: { [weak self]  value in
            self?.confirmEmailImageView.isHidden = isEmpty(value)
        }).disposed(by: disposeBag)
        viewModel.password.asObservable().subscribe(onNext: { [weak self]  value in
            
            if !isEmpty(value) && value.count < Constants.passwordMinLength {
                self?.passwordTextField.errorText = "TOO_SHORT_TEXT".app_localized
                self?.passwordTextField.showError(true)
            } else {
                self?.passwordTextField.errorText = ""
                self?.passwordTextField.showError(false)
            }
        }).disposed(by: disposeBag)
        viewModel.fullNameErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.nameTextField.errorText = message
            if message.isEmpty {
                self?.nameTextField.showError(false)
            } else {
                self?.nameTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        viewModel.emailErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.emailTextField.errorText = message
            if message.isEmpty {
                self?.emailTextField.showError(false)
            } else {
                self?.emailTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        viewModel.passwordErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.passwordTextField.errorText = message
            if message.isEmpty {
                self?.passwordTextField.showError(false)
            } else {
                self?.passwordTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.showErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            if !message.isEmpty {
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: message)
            }
        }).disposed(by: disposeBag)
        //
        signUpLabel.text = "SIGN_UP".app_localized
        nameTextField.titleText = "NAME_TEXT".app_localized
        emailTextField.titleText = "EMAIL_TEXT".app_localized
        passwordTextField.titleText = "PASSWORD_TITLE".app_localized
        nextLabel.text = "NEXT_TEXT".app_localized
        nameTextField.placeholder = "ENTER_YOUR_NAME_TEXT".app_localized
        emailTextField.placeholder = "ENTER_EMAIL_HERE_TEXT".app_localized
        passwordTextField.placeholder = "ENTER_PASSWORD_TEXT".app_localized
    }
    
    @IBAction func next(_ sender: Any) {
        if viewModel.validateAll() {
            view.endEditing(true)
            SVProgressHUD.show()
            viewModel.next { [weak self] error in
                SVProgressHUD.dismiss()
                guard let error = error else {
                    self?.app_showInfoAlert("SIGN_UP_SUCCESS_MESS".app_localized, title: "KOLEDA_TEXT".app_localized, completion: {
                        self?.logionApp()
                    })
                    return
                }
                self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func showOrHidePass(_ sender: Any) {
        viewModel?.showPassword(isShow: passwordTextField.isSecureTextEntry)
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
    private func logionApp() {
        SVProgressHUD.show()
        viewModel.loginAfterSignedUp(completion: { [weak self] errorMessage in
            SVProgressHUD.dismiss()
            if errorMessage != "" {
                self?.app_showInfoAlert(errorMessage, title: "ERROR_TITLE".app_localized, completion: {
                    self?.back()
                })
            } else {
                self?.viewModel.goTermAndConditions()
            }
        })
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == nameTextField {
            let currentText = textField.text as NSString?
            if let resultingText = currentText?.replacingCharacters(in: range, with: string) {
                return resultingText.count <= Constants.nameMaxLength
            }
        } else if textField == passwordTextField {
            let currentText = textField.text as NSString?
            if let resultingText = currentText?.replacingCharacters(in: range, with: string) {
                return resultingText.count <= Constants.passwordMaxLength
            }
        }
        return true
    }
}

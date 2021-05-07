//
//  LoginViewController.swift
//  Koleda
//
//  Created by Oanh tran on 6/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import SVProgressHUD
import AuthenticationServices

class LoginViewController: BaseViewController, BaseControllerProtocol, KeyboardAvoidable {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var loginGoogleButton: UIButton!
    @IBOutlet weak var loginFacebookButton: UIButton!
	@IBOutlet weak var loginAppleButton: UIButton!
    @IBOutlet weak var emailTextField: AndroidStyle2TextField!
    @IBOutlet weak var passwordTextField: AndroidStyle2TextField!
	@IBOutlet weak var appleLoginView: UIView!
    
    @IBOutlet weak var signInTitleLabel: UILabel!
    
    @IBOutlet weak var loginViaGoogeLabel: UILabel!
    @IBOutlet weak var loginViaFacebookLabel: UILabel!
    @IBOutlet weak var loginViaAppleLabel: UILabel!
    @IBOutlet weak var forgotPassLabel: UILabel!
    @IBOutlet weak var signInLabel: UILabel!
    
    var viewModel: LoginViewModelProtocol!
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
        statusBarStyle(with: .lightContent)
        self.edgesForExtendedLayout = UIRectEdge.top
        self.automaticallyAdjustsScrollViewInsets = false
        viewModel.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        viewModel.prepare(for: segue)
    }
    
    @IBAction func showOrHidePass(_ sender: Any) {
        viewModel.showPassword(isShow: passwordTextField.isSecureTextEntry)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        viewModel.forgotPassword()
    }
    
    @IBAction func login(_ sender: Any) {
        SVProgressHUD.show()
        loginButton.isEnabled = false
        viewModel.login { [weak self] isSuccess in
            SVProgressHUD.dismiss()
            self?.loginButton.isEnabled = true
            if !isSuccess {
                self?.app_showAlertMessage(title: "LOGIN_FAILED_TEXT".app_localized, message: "EMAIL_OR_PASS_IS_INVALID".app_localized)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        if self.navigationController?.viewControllers.count == 1 {
            viewModel.backOnboardingScreen()
        } else {
            back()
        }
    }
	
    func loginUsingGoogle() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func loginUsingFacebook() {
        let loginFBManager = LoginManager()
        
        loginFBManager.logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { [weak self] loginResult in
            switch loginResult {
            case .failed(let error):
                log.error(error.localizedDescription)
                self?.loginFacebookButton.isEnabled = true
                self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_FACEBOOK_MESS".app_localized)
            case .cancelled:
                log.info("User cancelled login.")
                self?.loginFacebookButton.isEnabled = true
                self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_FACEBOOK_MESS".app_localized)
            case .success(_, _, let fbAccessToken):
                SVProgressHUD.show()
                self?.viewModel.loginWithSocial(type: .facebook, accessToken: fbAccessToken.tokenString, completion: { [weak self] (isSuccess, error) in
                    self?.loginFacebookButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    guard let error = error, !isSuccess else {
                        return
                    }
                    if error == WSError.emailNotExisted {
                        self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: error.errorDescription)
                    } else {
                        self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: "LOGIN_FAILED_TRY_AGAIN_MESS".app_localized)
                    }
                })
            }
        }
    }
}

extension LoginViewController {
    private func configurationUI() {
        viewModel?.showPassword.asObservable().subscribe(onNext: { [weak self]  value in
            self?.passwordTextField.isSecureTextEntry = !value
        }).disposed(by: disposeBag)
        
        viewModel.email.asObservable().bind(to: emailTextField.rx.text).disposed(by: disposeBag)
        emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        viewModel.password.asObservable().bind(to: passwordTextField.rx.text).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
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
        
        loginGoogleButton.rx.tap.bind { [weak self] _ in
            self?.loginGoogleButton.isEnabled = false
            self?.loginUsingGoogle()
        }.disposed(by: disposeBag)
        
        loginFacebookButton.rx.tap.bind { [weak self] _ in
            self?.loginFacebookButton.isEnabled = false
            self?.loginUsingFacebook()
        }.disposed(by: disposeBag)
		setUpSignInAppleButton()
        signInTitleLabel.text = "SIGN_IN".app_localized
        emailTextField.titleText = "EMAIL_TITLE".app_localized
        passwordTextField.titleText = "PASSWORD_TITLE".app_localized
        emailTextField.placeholder = "ENTER_EMAIL_HERE_TEXT".app_localized
        passwordTextField.placeholder = "ENTER_PASSWORD_TEXT".app_localized
        loginViaFacebookLabel.text = "LOGIN_VIA_FACEBOOK".app_localized
        loginViaGoogeLabel.text = "LOGIN_VIA_GOOGLE".app_localized
        loginViaAppleLabel.text = "LOGIN_VIA_APPLE".app_localized
        forgotPassLabel.text = "FORGOT_PASSWORD".app_localized
        signInLabel.text = "SIGN_IN".app_localized

        
    }
	
	private func setUpSignInAppleButton() {
		if #available(iOS 13.0, *) {
			self.appleLoginView.isHidden = false
			loginAppleButton.rx.tap.bind { [weak self] _ in
				self?.confirmSharingAppleEmail()
			}.disposed(by: disposeBag)
		} else {
			// Fallback on earlier versions
			self.appleLoginView.isHidden = true
		}
	}
	
	private func loginWithApple() {
		if #available(iOS 13.0, *) {
			let appleIDProvider = ASAuthorizationAppleIDProvider()
			let request = appleIDProvider.createRequest()
			request.requestedScopes = [.fullName, .email]
			let authorizationController = ASAuthorizationController(authorizationRequests: [request])
			authorizationController.delegate = self
			authorizationController.performRequests()
		}
	}
	
	private func confirmSharingAppleEmail() {
		let OkAction = UIAlertAction(title: "OK".app_localized, style: .default) { [weak self] action in
			self?.loginAppleButton.isEnabled = false
			self?.loginWithApple()
		}
		
		let cancelAction = UIAlertAction(title: "CANCEL".app_localized, style: .cancel) { action in
			
		}
        app_showAlertMessage(title: "KOLEDA_TEXT".app_localized.app_localized,
                             message: "PLEASE_SELECT_SHARE_EMAIL_CONTINUE_WITH_APPLE_SIGN_IN".app_localized, actions: [cancelAction, OkAction])
	}
}

extension LoginViewController: ASAuthorizationControllerDelegate {
	@available(iOS 13.0, *)
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
			guard let authorizationCode = appleIDCredential.authorizationCode, let authCodeString = String(bytes: authorizationCode, encoding: .utf8)  else {
				loginAppleButton.isEnabled = true
                app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_APPLE_MESS".app_localized)
				return
			}
			SVProgressHUD.show()
			viewModel.loginWithSocial(type: .apple, accessToken: authCodeString) { [weak self] (isSuccess, error) in
				self?.loginAppleButton.isEnabled = true
				SVProgressHUD.dismiss()
				guard !isSuccess else {
					return
				}
				if error == WSError.hiddenAppleEmail {
                    self?.app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: error?.errorDescription)
				} else {
                    self?.app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: "LOGIN_FAILED_TRY_AGAIN_MESS".app_localized)
				}
			}
		}
	}
	
	@available(iOS 13.0, *)
	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		loginAppleButton.isEnabled = true
        app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_APPLE_MESS".app_localized)
	}
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == passwordTextField {
            let currentText = textField.text as NSString?
            if let resultingText = currentText?.replacingCharacters(in: range, with: string) {
                return resultingText.count <= Constants.passwordMaxLength
            }
        }
        return true
    }
}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            loginGoogleButton.isEnabled = true
            log.error("\(error.localizedDescription)")
            app_showAlertMessage(title: "LOGIN_GOOGLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_GOOGLE_MESS".app_localized)
        } else {
            // Perform any operations on signed in user here.
			guard let accessToken = user.authentication.accessToken else {
				loginGoogleButton.isEnabled = true
                app_showAlertMessage(title: "LOGIN_GOOGLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_GOOGLE_MESS".app_localized)
				return
			}
			SVProgressHUD.show()
			viewModel.loginWithSocial(type: .google, accessToken: accessToken) { [weak self] (isSuccess, error) in
				self?.loginGoogleButton.isEnabled = true
				SVProgressHUD.dismiss()
				if !isSuccess {
                    self?.app_showAlertMessage(title: "LOGIN_GOOGLE_FAILED_TEXT".app_localized, message: "LOGIN_FAILED_TRY_AGAIN_MESS".app_localized)
				}
			}
        }
    }
	
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}

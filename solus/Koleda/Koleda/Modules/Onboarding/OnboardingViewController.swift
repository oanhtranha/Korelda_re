//
//  OnboardingViewController.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import SVProgressHUD
import AuthenticationServices


class OnboardingViewController: BaseViewController, BaseControllerProtocol {
    var viewModel: OnboardingViewModelProtocol!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    private let disposeBag = DisposeBag()
	@IBOutlet weak var joinHomeButton: UIButton!
	@IBOutlet weak var appleLoginButton: UIButton!
	@IBOutlet weak var appleLoginView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var alreadyHaveAnAccountLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTransparency()
        statusBarStyle(with: .lightContent)
        configurationUI()
    }
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        viewModel.prepare(for: segue)
    }
 
    @IBAction func signUp(_ sender: Any) {
        viewModel.startSignUpFlow()
    }
    
	private func joinHome() {
		viewModel.joinHome()
	}
	
	@IBAction func signIn(_ sender: Any) {
        viewModel.startSignInFlow()
    }
}

extension OnboardingViewController: ASAuthorizationControllerDelegate {
	@available(iOS 13.0, *)
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
			guard let authorizationCode = appleIDCredential.authorizationCode, let authCodeString = String(bytes: authorizationCode, encoding: .utf8)  else {
				appleLoginButton.isEnabled = true
                app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_APPLE_MESS".app_localized)
				return
			}
			SVProgressHUD.show()
			viewModel.loginWithSocial(type: .apple, accessToken: authCodeString) { [weak self] (isSuccess, error) in
				self?.appleLoginButton.isEnabled = true
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
		appleLoginButton.isEnabled = true
        app_showAlertMessage(title: "LOGIN_APPLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_APPLE_MESS".app_localized)
	}
}

extension OnboardingViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            googleLoginButton.isEnabled = true
            log.error("\(error.localizedDescription)")
            app_showAlertMessage(title: "LOGIN_GOOGLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_GOOGLE_MESS".app_localized)
        } else {
            guard let accessToken = user.authentication.accessToken else {
                googleLoginButton.isEnabled = true
                app_showAlertMessage(title: "LOGIN_GOOGLE_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_GOOGLE_MESS".app_localized)
                return
            }
            SVProgressHUD.show()
            viewModel.loginWithSocial(type: .google, accessToken: accessToken) { [weak self] (isSuccess, error) in
                self?.googleLoginButton.isEnabled = true
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

extension OnboardingViewController {
    
    private func configurationUI() {
        googleLoginButton.rx.tap.bind { [weak self] _ in
            self?.googleLoginButton.isEnabled = false
            self?.loginUsingGoogle()
        }.disposed(by: disposeBag)
        
        facebookLoginButton.rx.tap.bind { [weak self] _ in
            self?.facebookLoginButton.isEnabled = false
            self?.loginUsingFacebook()
        }.disposed(by: disposeBag)
        
        joinHomeButton.rx.tap.bind { [weak self] _ in
            self?.joinHome()
        }.disposed(by: disposeBag)
        setUpSignInAppleButton()
        titleLabel.text = "WELCOME".app_localized
        subTitleLabel.text = "SUB_TITLE".app_localized
        signUpLabel.text = "SIGN_UP".app_localized
        facebookLabel.text = "CONTINUE_WITH_FACEBOOK".app_localized
        googleLabel.text = "CONTINUE_WITH_GOOGLE".app_localized
        appleButton.setTitle("CONTINUE_WITH_APPLE".app_localized, for: .normal)
        joinHomeButton.setTitle("JOIN_HOME".app_localized, for: .normal)
        alreadyHaveAnAccountLabel.text = "ALREADY_HAVE_A_ACCOUNT".app_localized
        loginLabel.text = "LOGIN".app_localized
    }
	
	private func setUpSignInAppleButton() {
		if #available(iOS 13.0, *) {
			self.appleLoginView.isHidden = false
			appleLoginButton.rx.tap.bind { [weak self] _ in
				self?.confirmSharingAppleEmail()
			}.disposed(by: disposeBag)
		} else {
			// Fallback on earlier versions
			self.appleLoginView.isHidden = true
		}
	}
	
	private func loginUsingGoogle() {
		GIDSignIn.sharedInstance()?.delegate = self
		GIDSignIn.sharedInstance()?.presentingViewController = self
		GIDSignIn.sharedInstance()?.signIn()
	}
	
	private func loginUsingFacebook() {
		let loginFBManager = LoginManager()
		loginFBManager.logOut()
		loginFBManager.logIn(permissions: [Permission.publicProfile, Permission.email], viewController: self) { [weak self] loginResult in
			switch loginResult {
			case .failed(let error):
				log.error(error.localizedDescription)
				self?.facebookLoginButton.isEnabled = true
                self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_FACEBOOK_MESS".app_localized)
			case .cancelled:
				self?.facebookLoginButton.isEnabled = true
                self?.app_showAlertMessage(title: "LOGIN_FACEBOOK_FAILED_TEXT".app_localized, message: "WE_CAN_NOT_LOGIN_FACEBOOK_MESS".app_localized)
			case .success(_, _, let fbAccessToken):
				SVProgressHUD.show()
				self?.viewModel.loginWithSocial(type: .facebook, accessToken: fbAccessToken.tokenString, completion: { (isSuccess, error) in
					self?.facebookLoginButton.isEnabled = true
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
			self?.appleLoginButton.isEnabled = false
			self?.loginWithApple()
		}
		
		let cancelAction = UIAlertAction(title: "CANCEL".app_localized, style: .cancel) { action in
			
		}
		app_showAlertMessage(title: "KOLEDA_TEXT".app_localized,
                             message: "PLEASE_SELECT_SHARE_EMAIL_CONTINUE_WITH_APPLE_SIGN_IN".app_localized, actions: [cancelAction, OkAction])
	}
}

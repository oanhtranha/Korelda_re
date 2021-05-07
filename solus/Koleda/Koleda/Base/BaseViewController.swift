//
//  BaseViewController.swift
//  Koleda
//
//  Created by Oanh tran on 5/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    
    private var isSubscribedToNoInternetNotifications = false
    private let noInternetPopupShowDuration = 5.0
    
    var canBackToPreviousScreen: Bool = true
    var closeButton: UIBarButtonItem?
    var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    private lazy var popupWindowManager = ManagerProvider.sharedInstance.popupWindowManager
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isSubscribedToNoInternetNotifications {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotConnectedToInternetNotification),
                                                   name: .KLDNotConnectedToInternet, object: nil)
            isSubscribedToNoInternetNotifications = true
        }
    }
    
    func addCloseFunctionality(_ tintColor: UIColor = UIColor.black) {
        let barButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(closeCurrentScreen))
        self.closeButton = barButtonItem
        closeButton?.apply(Style.BarButtonItem.closeLightBackground)
        closeButton?.tintColor = tintColor
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    
    
    func addLogoutButton() {
        let barButtonItem = UIBarButtonItem(title: "LOGOUT_TEXT".app_localized, style: .plain, target: self, action: #selector(logout))
        barButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func setTitleScreen(with title: String) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.app_FuturaPTDemi(ofSize: 30) ]
        self.title = title
    }
    
    func navigationBarTransparency() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.backBarButtonItem = .back_empty
    }
    
    func statusBarStyle(with type:  UIStatusBarStyle) {
        self.statusBarStyle = type
    }
    
    @objc func closeCurrentScreen() {
        if UserDefaultsManager.loggedIn.enabled {
            if canBackToPreviousScreen {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else if let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window {
            Launcher().presentOnboardingScreen(on: window)
        }
    }
    
    @objc func logout() {
        
    }
    
    @objc private func handleNotConnectedToInternetNotification(_ notification: NSNotification) {
        guard let ssid = FGRoute.getSSID(), ssid.contains("shelly") else {
            showNoInternetConnectionPopup()
            return
        }
    }
    
    func showNoInternetConnectionPopup() {
        
       
        
        let popupWindowManager = self.popupWindowManager
        DispatchQueue.main.async {
            guard !popupWindowManager.isShown else {
                return
            }
            
            guard let alertViewController = StoryboardScene.OfflineAlert.instantiateOfflineAlertViewController() as? Popup else { return }
            popupWindowManager.show(popup: alertViewController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.noInternetPopupShowDuration, execute: {
                popupWindowManager.hide(popup: alertViewController)
            })
        }
    }
    
}

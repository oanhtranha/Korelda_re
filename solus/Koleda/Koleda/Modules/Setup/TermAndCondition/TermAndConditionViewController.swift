//
//  TermAndConditionViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD
import WebKit
import CopilotAPIAccess

class TermAndConditionViewController: BaseViewController, BaseControllerProtocol, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var spaceToButton: NSLayoutConstraint!
    @IBOutlet weak var spaceToBottom: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var agreeAndContinueView: UIView!
    @IBOutlet weak var webViewContainerView: UIView!
    private var webView: WKWebView?
    @IBOutlet weak var termAndConditionLabel: UILabel!
    
    
    var viewModel: TermAndConditionViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addWebView()
        agreeButton.isEnabled = false
        let stringUrl = getUrlStringLink()
        guard let url = URL(string: stringUrl), let webView = self.webView else {
            return
        }
        let requestObj = URLRequest(url: url as URL)
        SVProgressHUD.show(withStatus: "LOADING_TEXT".app_localized)
        webView.load(requestObj)
        agreeAndContinueView.isHidden = (viewModel.legalItem.value == .termAndConditions) ? false : true
        spaceToButton.isActive = !agreeAndContinueView.isHidden
        spaceToBottom.isActive = agreeAndContinueView.isHidden
        agreeButton.rx.tap.bind { [weak self] _ in
            Copilot.instance.report.log(event: AcceptTermsAnalyticsEvent(version: "1.0"))
            self?.viewModel.showNextScreen()
        }.disposed(by: disposeBag)
        titleLabel.text = "PRIVACY_POLICY_TEXT".app_localized
        termAndConditionLabel.text = "AGREE_AND_CONTINUE_TEXT".app_localized
    }
    
    private func getUrlStringLink() -> String {
        switch viewModel.legalItem.value {
        case .legalPrivacyPolicy:
            titleLabel.text = "PRIVACY_POLICY_TEXT".app_localized
            return AppConstants.legalPrivacyPolicyLink
        case .legalTermAndConditions:
            titleLabel.text = "TERMS_AND_CONDITIONS_TEXT".app_localized
            return AppConstants.legalTermAndConditionLink
        default:
            return AppConstants.privacyPolicyLink
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        setTitleScreen(with: "")
    }
    
    @IBAction func backAction(_ sender: Any) {
        closeCurrentScreen()
    }
    
    private func addWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let size = CGSize.init(width: 0.0, height: self.webViewContainerView.frame.size.height)
        let customFrame = CGRect.init(origin: CGPoint.zero, size: size)
        self.webView = WKWebView (frame: customFrame, configuration: webConfiguration)
        if let webView = self.webView {
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.webViewContainerView.addSubview(webView)
            webView.topAnchor.constraint(equalTo: webViewContainerView.topAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: webViewContainerView.rightAnchor).isActive = true
            webView.leftAnchor.constraint(equalTo: webViewContainerView.leftAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: webViewContainerView.bottomAnchor).isActive = true
            webView.heightAnchor.constraint(equalTo: webViewContainerView.heightAnchor).isActive = true
            webView.uiDelegate = self
            webView.navigationDelegate = self
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish loading Term")
        agreeButton.isEnabled = true
        SVProgressHUD.dismiss()
    }
}

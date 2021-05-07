//
//  HtmlDialogDefaultView.swift
//  CopilotAPIAccess
//
//  Created by Elad on 05/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/// The main view of the popup dialog
 class HtmlDialogView: UIView {


    var webContent: String? {
        willSet {
            if let webContent = newValue {
                let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
                webview.loadHTMLString(headerString + webContent, baseURL: nil)
                }
        }
    }
    
    // MARK: - Views

    /// The view that will contain the image, if set
    lazy var webview: WKWebView  = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()


    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false

        // Layout views
        
        addSubview(webview)
        
        webview.anchorToSuperview()

    }
}

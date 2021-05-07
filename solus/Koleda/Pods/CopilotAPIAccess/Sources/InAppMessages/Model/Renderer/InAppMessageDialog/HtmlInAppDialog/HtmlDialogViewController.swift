//
//  HtmlPopupDialogViewController.swift
//  CopilotAPIAccess
//
//  Created by Elad on 05/03/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import WebKit

class HtmlDialogViewController: UIViewController {

    var htmlView: HtmlDialogView {
       return view as! HtmlDialogView // swiftlint:disable:this force_cast
    }

    override func loadView() {
        super.loadView()
        view = HtmlDialogView(frame: .zero)
    }
}

extension HtmlDialogViewController {
    // MARK: Content
    
    var webContent: String? {
        get { return htmlView.webContent }
        set { htmlView.webContent = newValue }
    }
}

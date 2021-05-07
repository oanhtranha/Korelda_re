//
//  ManySensorsDetectedPopupViewController.swift
//  Koleda
//
//  Created by Oanh tran on 8/7/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ManySensorsDetectedPopupViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: .KLDNeedToReSearchDevices, object: nil)
        }
    }
}

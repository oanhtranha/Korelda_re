//
//  PassthroughViewController.swift
//
//  Created by Iurii Pleskach on 4/6/18.
// 
//

import UIKit

class PassthroughViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override open func loadView() {
        super.loadView()
        view = PassthroughView()
        view.backgroundColor = .clear
    }
}

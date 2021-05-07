//
//  WelcomeJoinHomeViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 8/5/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeJoinHomeViewController:  BaseViewController, BaseControllerProtocol {

    @IBOutlet weak var nextButton: UIButton!
    var viewModel: WelcomeJoinHomeViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func nextAction(_ sender: Any) {
        viewModel.goHome()
    }
}

//
//  SyncViewController.swift
//  Koleda
//
//  Created by Oanh tran on 6/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SyncViewController: BaseViewController, BaseControllerProtocol {
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameProfileLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var viewModel: SyncViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        addCloseFunctionality()
        setTitleScreen(with: "")
    }

}

extension SyncViewController {
    private func configurationUI() {
        Style.View.shadowStyle1.apply(to: profileView)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        profileImageView.layer.masksToBounds = true
        viewModel?.profileImage.drive(profileImageView.rx.image).disposed(by: disposeBag)
        noButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.showTermAndConditionScreen()
        }.disposed(by: disposeBag)
//        yesButton.rx.tap.bind { [weak self] _ in
//            self?.viewModel.showTermAndConditionScreen()
//            }.disposed(by: disposeBag)
    }
}

//
//  HeatersManagementViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class HeatersManagementViewController:  BaseViewController, BaseControllerProtocol {
    var viewModel: HeatersManagementViewModelProtocol!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heatersLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var heatersCollectionView: UICollectionView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.viewWillAppear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateSelectedRoom),
                                               name: .KLDNeedUpdateSelectedRoom, object: nil)
        viewModel.heaters.asObservable().subscribe(onNext: { [weak self] heaters in
            guard  let viewModel = self?.viewModel, let heatersCollectionViewDataSource = self?.heatersCollectionView.dataSource as? HeatersManagementCollectionViewDataSource else { return }
            heatersCollectionViewDataSource.heaters = heaters
            heatersCollectionViewDataSource.viewModel = viewModel
            self?.heatersCollectionView.reloadData()
        }).disposed(by: disposeBag)
        
        doneButton.rx.tap.bind { [weak self] in
            self?.viewModel.doneAction()
        }.disposed(by: disposeBag)
        
//        addHeaterButton.rx.tap.bind { [weak self] in
//            self?.viewModel.addHeaterFlow()
//        }
        viewModel.showDeleteConfirmMessage.asObservable().subscribe(onNext: { [weak self] show in
            if show {
                self?.showDeleteConfirmMessage()
            }
        }).disposed(by: disposeBag)
        heatersLabel.text = "EDIT_HEATERS_TEXT".app_localized
        confirmLabel.text = "CONFIRM_TEXT".app_localized
//        heaterTitleLabel.text = "Heaters".app_localized
    }
    
    func showDeleteConfirmMessage() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickLetfButton = {
                self.showConfirmPopUp()
            }
            if let removingHeaterName: String = viewModel.removingHeaterName{
                vc.typeAlert = .deleteHeater(heaterName: removingHeaterName)
            }
            showPopup(vc)
        }
    }
    
    private func showConfirmPopUp() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickRightButton = {
                SVProgressHUD.show()
                self.viewModel.callServiceDeleteHeater(completion: { isSuccess in
                    SVProgressHUD.dismiss()
                    if isSuccess {
                        NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
                        self.app_showInfoAlert("DELETED_HEATER_SUCCESS_MESS".app_localized)
                    } else {
                        self.app_showInfoAlert("CAN_NOT_DELETE_HEATER".app_localized)
                    }
                })
            }
            vc.typeAlert = .confirmDeleteHeater
            showPopup(vc)
        }
    }
    
    @objc private func needUpdateSelectedRoom() {
        viewModel.needUpdateSelectedRoom()
    }
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
}

extension HeatersManagementViewController :  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.heatersCollectionView.frame.width, height: 98)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

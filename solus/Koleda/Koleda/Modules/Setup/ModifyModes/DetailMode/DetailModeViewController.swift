//
//  DetailModeViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 2/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class DetailModeViewController: BaseViewController, BaseControllerProtocol {
   
    var viewModel: DetailModeViewModelProtocol!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var modeNameTextField: AndroidStyle3TextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var editModeLabel: UILabel!
    @IBOutlet weak var targetTemperatureLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private var currentIndexPath: IndexPath?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        statusBarStyle(with: .lightContent)
        setTitleScreen(with: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    @IBAction func backAction(_ sender: Any) {
        viewModel.backToModifyModes()
    }
    
    override func viewDidLayoutSubviews() {
        if let indexPath = currentIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        viewModel.confirmed()
    }
    
    private func configurationUI() {
        viewModel.selectedMode.asObservable().subscribe(onNext: { [weak self] selectedMode in
            guard let mode = selectedMode?.mode, let currentTemp = selectedMode?.temperature.integerPart() else {
                return
            }
            self?.modeNameTextField.text = ModeItem.modeNameOf(smartMode: mode)
            self?.viewModel?.didSelectedTemperature(temp: currentTemp)
            if let index = self?.viewModel.tempList.firstIndex(of: currentTemp) {
                self?.currentIndexPath = IndexPath(row: 0, section: index)
            }
        }).disposed(by: disposeBag)
        
        viewModel.reloadCollectionView.asObservable().subscribe(onNext: { [weak self] in
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.showErrorMessage.asObservable().subscribe(onNext: { [weak self] messsage in
            self?.app_showAlertMessage(title: "ERROR_TITLE", message: messsage)
        }).disposed(by: disposeBag)
        editModeLabel.text = "EDIT_MODE_TEXT".app_localized
        modeNameTextField.titleText = "MODE_TEXT".app_localized
        targetTemperatureLabel.text = "TARGET_TEMPERATURE".app_localized
        confirmButton.setTitle("CONFIRM_TEXT".app_localized, for: .normal)
    }
}

extension DetailModeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 58, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension DetailModeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTemp = viewModel.tempList[indexPath.section]
        viewModel?.didSelectedTemperature(temp: selectedTemp)
    }
}

extension DetailModeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.tempList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "TemperatureCollectionViewCell",
                                 for: indexPath) as? TemperatureCollectionViewCell else {
                                    fatalError()
        }
        let temp = viewModel.tempList[indexPath.section]
        cell.setup(temp: temp, currentTempOfMode: viewModel.currentTemperature)
        return cell
    }
}


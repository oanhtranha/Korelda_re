//
//  ModifyModesViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 2/3/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class ModifyModesViewController: BaseViewController, BaseControllerProtocol {
    var viewModel: ModifyModesViewModelProtocol!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var customTemperatureLabel: UILabel!
    
    @IBOutlet weak var modesCollectionView: UICollectionView!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setTitleScreen(with: "")
    }
    
    @objc private func needReLoadModes() {
        viewModel.loadModes()
    }
    
    private func initView() {
        viewModel.smartModes.asObservable().subscribe(onNext: { [weak self] smartModes in
            guard let modesCollectionViewDataSource = self?.modesCollectionView.dataSource as? ModesCollectionViewDataSource else { return }
            modesCollectionViewDataSource.smartModes = smartModes
            modesCollectionViewDataSource.fromModifyModesScreen = true
            self?.modesCollectionView.reloadData()
        }).disposed(by: disposeBag)
        NotificationCenter.default.addObserver(self, selector: #selector(needReLoadModes), name: .KLDNeedReLoadModes, object: nil)
        titleLabel.text = "MODIFY_TEMPERATURE_MODE_TEXT".app_localized
        descriptionLabel.text = "HERE_YOU_CAN_MODIFY_TEMPERATURE_MODES_APPLY_TO_ROOM".app_localized
        customTemperatureLabel.text = "CUSTOM_TEMPERATURES_TEXT".app_localized
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
}

extension ModifyModesViewController :  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCells = viewModel.smartModes.value.count
        let widthOfCell: CGFloat = self.modesCollectionView.frame.width / CGFloat(numberOfCells)
        return CGSize(width: (widthOfCell > 88) ? widthOfCell : 88, height: self.modesCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension ModifyModesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectMode(atIndex: indexPath.section)
    }
}

//
//  ConfigurationRoomViewController.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class ConfigurationRoomViewController: BaseViewController, BaseControllerProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editRoomButton: UIButton!
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var devicesInfoView: UIView!
    @IBOutlet weak var paireddWithSensorTitleLabel: UILabel!
    @IBOutlet weak var sensorManagementButton: UIButton!
    @IBOutlet weak var heatersCollectionView: UICollectionView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var editRoomDetailsLabel: UILabel!
    @IBOutlet weak var heatersTitleLabel: UILabel!
    @IBOutlet weak var managementTitleLabel: UILabel!
    @IBOutlet weak var manageRoomLabel: UILabel!
    @IBOutlet weak var heaterManagementLabel: UILabel!
    @IBOutlet weak var sensorManagenentLabel: UILabel!
    
    @IBOutlet var heatersDataSource: HeatersCollectionViewDataSource!
    private let disposeBag = DisposeBag()
    
    var viewModel: ConfigurationRoomViewModelProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        statusBarStyle(with: .lightContent)
        viewModel.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func needUpdateSelectedRoom() {
        viewModel.needUpdateSelectedRoom()
    }
    
    private func configurationUI() {
        // Room Info view
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateSelectedRoom),
                                               name: .KLDNeedUpdateSelectedRoom, object: nil)
        viewModel.temperature.asObservable().bind(to: temperatureLabel.rx.text).disposed(by: disposeBag)
        editRoomButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.editRoom()
        }.disposed(by: disposeBag)
        
        sensorManagementButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.sensorManagement()
        }.disposed(by: disposeBag)
        
        viewModel.title.asObservable().bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.imageRoom.asObserver().bind(to: roomImageView.rx.image).disposed(by: disposeBag)
        
        viewModel.imageRoomColor.asObservable().subscribe(onNext: { [weak self] color in
            self?.roomImageView.tintColor = color
        }).disposed(by: disposeBag)
        // Devices Info View
        viewModel.heaters.asObservable().subscribe(onNext: { [weak self] heaters in
            guard let heatersCollectionViewDataSource = self?.heatersCollectionView.dataSource as? HeatersCollectionViewDataSource else { return }
            heatersCollectionViewDataSource.heaters = heaters
            self?.heatersCollectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.pairedWithSensorTitle.asObservable().bind(to: paireddWithSensorTitleLabel.rx.text).disposed(by: disposeBag)
        editRoomDetailsLabel.text = "EDIT_ROOM_DETAILS_TEXT".app_localized
        heatersTitleLabel.text = "HEATERS_TEXT".app_localized
        managementTitleLabel.text = "MANAGEMENT_TEXT".app_localized
        manageRoomLabel.text = "MANAGE_ROOM_TEXT".app_localized
        heaterManagementLabel.text = "HEATER_MANAGEMENT_TEXT".app_localized
        sensorManagenentLabel.text = "SENSOR_MANAGEMENT_TEXT".app_localized
    }
    
    @IBAction func heaterManagementAction(_ sender: Any) {
        self.viewModel.heatersManagement()
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
}

extension ConfigurationRoomViewController :  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCells = viewModel.heaters.value.count
        let widthOfCell: CGFloat = self.heatersCollectionView.frame.width / CGFloat(numberOfCells)
        return CGSize(width: 311, height: 98)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

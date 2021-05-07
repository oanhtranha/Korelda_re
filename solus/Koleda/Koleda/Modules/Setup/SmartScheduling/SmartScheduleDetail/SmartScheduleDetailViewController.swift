//
//  SmartScheduleDetailViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class SmartScheduleDetailViewController:  BaseViewController, BaseControllerProtocol {
    var viewModel: SmartScheduleDetailViewModelProtocol!
    @IBOutlet weak var modifyTimeslotLabel: UILabel!
    @IBOutlet weak var timeslotTitleLabel: UILabel!
    @IBOutlet weak var leftLineImageView: UIImageView!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeTitleLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var modeIconImageView: UIImageView!
    @IBOutlet weak var modeTitleLabel: UILabel!
    @IBOutlet weak var modeTemperatureLabel: UILabel!
    @IBOutlet weak var modeUnitOfTempLabel: UILabel!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var selectModeLabel: UILabel!
    
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var addRoomButton: UIButton!
    @IBOutlet weak var modesCollectionView: UICollectionView!
    
    @IBOutlet weak var applyToAllRoomsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var okayButton: UIButton!
    
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationBarTransparency()
        statusBarStyle(with: .lightContent)
        setTitleScreen(with: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? RoomsPopOverViewController {
            viewController.delegate = self
            viewController.selectedRooms = viewModel.selectedRooms.value
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
    @IBAction func startTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .scheduleStartTime
            guard let startTime = startTimeLabel.text, let endTime = endTimeLabel.text else {
                return
            }
            vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            vc?.scheduleTimeInputDelegate = self
        }
    }
    
    @IBAction func endTimeAction(_ sender: Any) {
        gotoBlock(withStoryboar: "Setup", aClass: EnergyTariffInputViewController.self) { (vc) in
            vc?.typeInput = .scheduleEndTime
            guard let startTime = startTimeLabel.text, var endTime = endTimeLabel.text else {
                return
            }
            vc?.startTime = Date(str: startTime, format: Date.fm_HHmm)
            if endTime.timeValue()?.timeIntValue() == Constants.MAX_TIME_DAY {
                endTime = "00:00"
            }
            vc?.endTime = Date(str: endTime, format: Date.fm_HHmm)
            vc?.scheduleTimeInputDelegate = self
        }
    }
    
    private func initView() {
        viewModel.timeslotTitle.asObservable().bind(to: timeslotTitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.hiddenDeleteButton.asObservable().bind(to: deleteButton.rx.isHidden).disposed(by: disposeBag)
        applyToAllRoomsButton.rx.tap.bind { [weak self] in
            self?.viewModel.selectedRooms.value = UserDataManager.shared.rooms
        }.disposed(by: disposeBag)
        addRoomButton.rx.tap.bind { [weak self] in
            self?.performSegue(withIdentifier: RoomsPopOverViewController.get_identifier, sender: self)
        }.disposed(by: disposeBag)
        okayButton.rx.tap.bind { [weak self] in
            self?.okayButton.isEnabled = false
            self?.viewModel.updateSchedules { [weak self] isSuccess in
                self?.okayButton.isEnabled = true
                if isSuccess {
                    self?.back()
                } else {
                    self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "CAN_NOT_UPDATE_SMART_SCHEDULE_MESS".app_localized)
                }
            }
        }.disposed(by: disposeBag)
        deleteButton.rx.tap.bind { [weak self] in
            self?.okayButton.isEnabled = false
            self?.viewModel.deleteSchedules { [weak self] isSuccess in
                self?.okayButton.isEnabled = true
                if isSuccess {
                    self?.back()
                }
            }
        }.disposed(by: disposeBag)
        viewModel.selectedRooms.asObservable().subscribe(onNext: { [weak self] _ in
            self?.roomsTableView.reloadData()
        }).disposed(by: disposeBag)
        viewModel.smartModes.asObservable().subscribe(onNext: { [weak self] smartModes in
            guard let modesCollectionViewDataSource = self?.modesCollectionView.dataSource as? ModesCollectionViewDataSource else { return }
            modesCollectionViewDataSource.smartModes = smartModes
        }).disposed(by: disposeBag)
        viewModel.selectedMode.asObservable().subscribe(onNext: { [weak self] _ in
            guard  let viewModel = self?.viewModel, let modesCollectionViewDataSource = self?.modesCollectionView.dataSource as? ModesCollectionViewDataSource else { return }
            modesCollectionViewDataSource.smartModes = viewModel.smartModes.value
            modesCollectionViewDataSource.selectedMode = viewModel.selectedMode.value
            self?.modesCollectionView.reloadData()
            guard let selectedMode = viewModel.selectedMode.value else {
                return
            }
            self?.updateModeView(mode: selectedMode)
        }).disposed(by: disposeBag)
        
        //
        
        viewModel.startTime.asObservable().bind(to: startTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.endTime.asObservable().bind(to: endTimeLabel.rx.text).disposed(by: disposeBag)
        viewModel.showMessageError.asObservable().subscribe(onNext: { [weak self] errorMessage in
            self?.app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: errorMessage)
        }).disposed(by: disposeBag)
        deleteButton.setTitle("DELETE".app_localized, for: .normal)
        modifyTimeslotLabel.text = "MODIFY_TIMESLOT_TEXT".app_localized
        applyToAllRoomsButton.setTitle("APPLIED_TO_ALL_ROOMS".app_localized, for: .normal)
        startTimeTitleLabel.text = "START_TEXT".app_localized
        endTimeTitleLabel.text = "END_TEXT".app_localized
        roomsLabel.text = "ROOMS_TEXT".app_localized
        addRoomButton.setTitle("ADD_ROOM_TO_TIMESLOT".app_localized, for:.normal)
        selectModeLabel.text = "SELECT_MODE_TEXT".app_localized
        okayButton.setTitle("CONFIRM_TEXT".app_localized, for: .normal)
    }
    
    private func updateModeView(mode: ModeItem) {
        modeIconImageView.image = mode.icon
        modeIconImageView.tintColor = mode.color
        leftLineImageView.tintColor = mode.color
        modeTitleLabel.text = mode.title
        
        if UserDataManager.shared.temperatureUnit == .C {
            modeTemperatureLabel.text = mode.temperature.toString()
            modeUnitOfTempLabel.text = "°C"
        } else {
            modeTemperatureLabel.text = mode.temperature.fahrenheitTemperature.toString()
            modeUnitOfTempLabel.text = "°F"
        }
        
    }
}

extension SmartScheduleDetailViewController: ScheduleTimeInputDelegate {
    func selectedTime(start: String, end: String) {
        viewModel.startTime.value = start
        if end == "00:00" {
            viewModel.endTime.value = "24:00"
        } else {
            viewModel.endTime.value = end
        }
    }
}

extension SmartScheduleDetailViewController: RoomsPopOverViewControllerDelegate {
    func didSelected(rooms: [Room]) {
        viewModel.selectedRooms.value = rooms
    }
}

extension SmartScheduleDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.selectedRooms.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = roomsTableView.dequeueReusableCell(withIdentifier: ScheduleRoomCell.get_identifier, for: indexPath) as? ScheduleRoomCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let room = viewModel.selectedRooms.value[indexPath.row]
        cell.setup(withRoom: room)
        cell.closeButtonHandler = { [weak self] (room) in
            if let indexRoom = self?.viewModel.selectedRooms.value.firstIndex(where: {$0.id == room.id}) {
                self?.viewModel.selectedRooms.value.remove(at: indexRoom)
                self?.roomsTableView.reloadData()
            }
        }
        return cell
    }
}

extension SmartScheduleDetailViewController :  UICollectionViewDelegateFlowLayout {
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

extension SmartScheduleDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectMode(atIndex: indexPath.section)
    }
}

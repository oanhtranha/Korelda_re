//
//  HomeViewController.swift
//  Koleda
//
//  Created by Oanh tran on 6/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SwiftRichString
import SVProgressHUD
import CopilotAPIAccess

class HomeViewController: BaseViewController, BaseControllerProtocol {

    var viewModel: HomeViewModelProtocol!
    @IBOutlet weak var addARoomButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    private let disposeBag = DisposeBag()
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var homeInitialView: UIView!
    @IBOutlet weak var userHomeTitle: UILabel!
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var descriptionTitleLabel: UILabel!
    @IBOutlet weak var addRoomLabel: UILabel!
    @IBOutlet weak var letsGetStartLabel: UILabel!
    @IBOutlet weak var addTheFirstRoomLabel: UILabel!
    
    @IBOutlet var roomsTableViewDataSource: RoomsTableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
        addRefreshControl()
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        roomsTableView.addSubview(refreshControl!)
    }
    
    @objc private func refreshList() {
        viewModel.refreshListRooms()
        refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeViewController {
    
    @objc private func refreshListRooms(_ notification: NSNotification) {
        viewModel.refreshListRooms()
    }
    
    @objc private func didChangeWifi() {
        guard self.navigationController?.top is HomeViewController else {
            return
        }
        viewModel.refreshListRooms()
        guard let userName = UserDataManager.shared.currentUser?.name else {
            viewModel.getCurrentUser()
            return
        }
    }
    
    @objc private func refreshTempModes(_ notification: NSNotification) {
        viewModel.refreshSettingModes()
    }
    
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshListRooms),
                                               name: .KLDDidChangeRooms, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeWifi),
                                               name: .KLDDidChangeWifi, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTempModes),
                                               name: .KLDDidUpdateTemperatureModes, object: nil)
        settingButton.rx.tap.bind { [weak self] _ in
            Copilot.instance.report.log(event: TapMenuItemAnalyticsEvent(menuItem: "Settings"))
            self?.viewModel.showMenuSettings()
        }.disposed(by: disposeBag)
        addARoomButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.addRoom()
        }.disposed(by: disposeBag)
        
        viewModel.homeTitle.asObservable().bind { [weak self] title in
            let normal = SwiftRichString.Style{
                $0.font = UIFont.app_FuturaPTLight(ofSize: 32)
                $0.color = UIColor.hex1F1B15
            }
            
            let bold = SwiftRichString.Style {
                $0.font = UIFont.app_FuturaPTDemi(ofSize: 32)
                $0.color = UIColor.hex1F1B15
            }
            
            let group = StyleGroup(base: normal, ["h1": bold])
            self?.userHomeTitle?.attributedText = title.set(style: group)
        }.disposed(by: disposeBag)
        
        viewModel.rooms.asObservable().subscribe(onNext: { [weak self] rooms in
            if rooms.count > 0 {
                self?.roomsTableView.isHidden = false
                self?.homeInitialView.isHidden = true
                self?.roomsTableViewDataSource.rooms = rooms
                self?.roomsTableViewDataSource.viewModel = self?.viewModel
                self?.roomsTableView.dataSource = self?.roomsTableViewDataSource
                self?.roomsTableView.delegate = self
                self?.roomsTableView.reloadData()
            } else {
                self?.roomsTableView.isHidden = true
                self?.homeInitialView.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        viewModel.mustLogOutApp.asObservable().subscribe(onNext: { [weak self] errorMessage in
            self?.app_showInfoAlert(errorMessage, title: "KOLEDA_TEXT".app_localized, completion: {
                self?.viewModel.logOut()
            })
        }).disposed(by: disposeBag)
        descriptionTitleLabel.text = "THIS_IS_YOUR_DASHBOARD".app_localized
        letsGetStartLabel.text = "LETS_GET_STARTED_SETTING_UP_YOUR_SOLUS".app_localized
        addTheFirstRoomLabel.text = "ADD_THE_FIRST_ROOM_MESS".app_localized
        addRoomLabel.text = "ADD_A_ROOM_TEXT".app_localized
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRoom(at: indexPath)
    }
}



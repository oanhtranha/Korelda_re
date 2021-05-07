//
//  ListRoomViewController.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SwiftRichString

class ListRoomViewController: BaseViewController, BaseControllerProtocol {
    
    var viewModel: HomeViewModel!
    @IBOutlet weak var settingButton: UIButton!
    private let disposeBag = DisposeBag()
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var homeInitialView: UIView!
    @IBOutlet weak var roomsTableView: UITableView!
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

extension ListRoomViewController {
    
    @objc private func refreshListRooms(_ notification: NSNotification) {
        viewModel.refreshListRooms()
    }
    
    @objc private func didChangeWifi() {
        viewModel.refreshListRooms()
        guard let userName = UserDataManager.shared.currentUser?.name else {
            viewModel.getCurrentUser()
            return
        }
    }
    
    private func configurationUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshListRooms),
                                               name: .KLDDidChangeRooms, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeWifi),
                                               name: .KLDDidChangeWifi, object: nil)
        settingButton.rx.tap.bind { [weak self] _ in
            self?.back()
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
    }
}

extension ListRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRoomConfiguration(at: indexPath)
    }
}

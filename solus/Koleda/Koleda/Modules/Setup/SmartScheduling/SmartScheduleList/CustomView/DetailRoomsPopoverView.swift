//
//  DetailRoomsPopoverView.swift
//  Koleda
//
//  Created by Oanh tran on 11/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class DetailRoomsPopoverView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var rooms: [Room] = []
    var targetTemperature: Double = 0
    private let currentTempUnit = UserDataManager.shared.temperatureUnit.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    func reloadData(rooms: [Room]) {
        self.rooms = rooms
        tableView.reloadData()
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension DetailRoomsPopoverView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.get_identifier, for: indexPath) as? ScheduleTableViewCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let room = self.rooms[indexPath.row]
        let scheduleRow = ScheduleRow(type: .Detail, title: room.name, icon: nil, temp: room.temperature?.kld_doubleValue, unit: currentTempUnit)
        cell.setup(scheduleRow: scheduleRow, targetTemperature: targetTemperature)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}


//
//  RoomsTableViewDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 7/15/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class RoomsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var rooms: [Room] = []
    var viewModel: HomeViewModelProtocol?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCell.get_identifier, for: indexPath) as? HomeCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let room = self.rooms[indexPath.section]
        cell.loadData(room: RoomViewModel(room: room))
        return cell
    }
}


//
//  RoomsPopOverViewController.swift
//  Koleda
//
//  Created by Oanh tran on 9/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

protocol RoomsPopOverViewControllerDelegate: class {
    func didSelected(rooms: [Room])
}


class RoomsPopOverViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: RoomsPopOverViewControllerDelegate?
    private let disposeBag = DisposeBag()
    
    var rooms: [Room] = []
    var selectedRooms: [Room] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        rooms = UserDataManager.shared.rooms
        Style.View.shadowCornerWhite.apply(to: containerView)
        tableView.reloadData()
        okButton.rx.tap.bind {
            self.dismiss(animated: true, completion: {
                self.delegate?.didSelected(rooms: self.selectedRooms)
            })
        }.disposed(by: disposeBag)
        titleLabel.text = "PLEASE_SELECT_ROOMS".app_localized
        okButton.setTitle("OK".app_localized, for: .normal)
        
    }
}

extension RoomsPopOverViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomPopOverCell.get_identifier, for: indexPath) as? RoomPopOverCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let room = rooms[indexPath.row]
        cell.accessoryType = .none
        let isSelected = selectedRooms.filter {$0.id == room.id}.count > 0
        cell.loadData(room: room, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RoomPopOverCell {
            cell.checkMarkImageView.isHidden = false
            updateRooms(isSelected: true, room: rooms[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RoomPopOverCell {
            cell.checkMarkImageView.isHidden = true
            updateRooms(isSelected: false, room: rooms[indexPath.row])
        }
    }
    
    private func updateRooms(isSelected: Bool, room: Room) {
        let hasRoom = selectedRooms.filter {$0.id == room.id}.count > 0
        if isSelected && !hasRoom {
            selectedRooms.append(room)
        } else {
            if let indexRoom = self.selectedRooms.firstIndex(where: {$0.id == room.id}), !isSelected {
                self.selectedRooms.remove(at: indexRoom)
            }
        }
            
    }
}


//
//  ScheduleViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topLineImageView: UIImageView!
    @IBOutlet weak var bottomLineImageView: UIImageView!
    private var rooms: [Room] = []
    private var rows: [ScheduleRow] = []
    private var targetTemperature: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = self.view.frame
        topLineImageView.frame = CGRect(x: topLineImageView.frame.origin.x, y: tableView.frame.origin.y, width: topLineImageView.frame.width, height: topLineImageView.frame.height)
        bottomLineImageView.frame = CGRect(x: bottomLineImageView.frame.origin.x, y: tableView.frame.origin.y + tableView.frame.height - 2, width: bottomLineImageView.frame.width, height: bottomLineImageView.frame.height)
    }
    
    func reloadData(content: ScheduleBlock?) {
        guard let content = content else {
            return
        }
        targetTemperature = content.targetTemperature
        updateView(color: content.color)
        rooms = content.rooms
        self.rows = content.scheduleRows
        tableView.reloadData()
    }
    
    func updateView(color: UIColor) {
        topLineImageView.tintColor = color
        bottomLineImageView.tintColor = color
        tableView.layer.cornerRadius = 10
        tableView.layer.shadowColor = color.cgColor
        tableView.layer.shadowOffset = CGSize(width: 3, height: 3)
        tableView.layer.shadowOpacity = 0.7
        tableView.layer.shadowRadius = 10
//        self.tableView.backgroundColor = UIColor.white
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = rows[indexPath.row]
        if row.type == .Header {
            return 47
        } else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row.type {
        case .Header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleHeaderCell.get_identifier, for: indexPath) as? ScheduleHeaderCell else {
                log.error("Invalid cell type call")
                return UITableViewCell()
            }
            cell.setup(scheduleRow: row)
            return cell
        case .Footer:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleFooterCell.get_identifier, for: indexPath) as? ScheduleFooterCell else {
                log.error("Invalid cell type call")
                return UITableViewCell()
            }
            cell.setup(scheduleRow: row)
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.get_identifier, for: indexPath) as? ScheduleTableViewCell else {
                log.error("Invalid cell type call")
                return UITableViewCell()
            }
            cell.setup(scheduleRow: row, targetTemperature: targetTemperature)
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if rows.count == 1 && indexPath.row == 0 || indexPath.row == rows.count - 1 {
//            showPopover(indexPath: indexPath)
//        }
//    }
//    
//    private func showPopover(indexPath: IndexPath) {
//        guard rooms.count > 0, let cell = tableView.cellForRow(at: indexPath) else {
//            return
//        }
//        guard let detailRoomsPopoverView = StoryboardScene.SmartSchedule.instantiateDetailRoomsPopoverView() as? DetailRoomsPopoverView else { return }
//        detailRoomsPopoverView.view.backgroundColor = self.tableView.backgroundColor
//        detailRoomsPopoverView.targetTemperature = targetTemperature
//        detailRoomsPopoverView.rooms = rooms
//        detailRoomsPopoverView.modalPresentationStyle = .popover
//        let heighOfPopoverView = rooms.count*45 + 5
//        detailRoomsPopoverView.preferredContentSize = CGSize(width: tableView.frame.size.width, height: CGFloat(heighOfPopoverView))
//        let presentationController = detailRoomsPopoverView.popoverPresentationController
//        presentationController?.delegate = self
//        presentationController?.permittedArrowDirections = .up
//        presentationController?.sourceView = cell
//        presentationController?.sourceRect = cell.bounds
//        present(detailRoomsPopoverView, animated: true, completion: nil)
//    }
}

//extension ScheduleViewController: UIPopoverPresentationControllerDelegate {
//    func adaptivePresentationStyle(for controller: UIPresentationController,
//                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
//        return .none
//    }
//}

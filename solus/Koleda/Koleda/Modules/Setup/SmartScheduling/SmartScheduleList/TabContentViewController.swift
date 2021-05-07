//
//  TabContentViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SpreadsheetView
import SVProgressHUD

protocol TabContentViewControllerDelegate: class {
    func showScheduleDetailScreen(startTime: Time, day: DayOfWeek, tapedTimeline: Bool)
}

class TabContentViewController: BaseViewController, BaseControllerProtocol {
    var viewModel: TabContentViewModelProtocol!
    weak var delegate: TabContentViewControllerDelegate?
    private let disposeBag = DisposeBag()

    @IBOutlet weak var schedulesView: SpreadsheetView!
    
    @IBOutlet weak var addSmartScheduleButton: UIButton!
    
    static func instantiate(dayOfWeek: DayOfWeek) -> TabContentViewController? {
        guard let viewController = StoryboardScene.SmartSchedule.instantiateTabContentViewController() as? TabContentViewController else {
            assertionFailure("Setup storyboard configured not properly")
            return nil
        }
        let router = TabContentRouter()
        let viewModel = TabContentViewModel.init(router: router)
        viewModel.setup(dayOfWeek: dayOfWeek)
        viewController.viewModel = viewModel
        router.baseViewController = viewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationSheetView()
        viewModel.reloadScheduleView.asObservable().subscribe(onNext: { [weak self] in
            self?.schedulesView.reloadData()
            self?.addSmartScheduleButton.isHidden = self?.viewModel.scheduleOfDayViewModel.displayData.count != 0
        }).disposed(by: disposeBag)
        addSmartScheduleButton.rx.tap.bind { [weak self] in
            let startTime = Time(hour: 0, minute: 0)
            guard let dayOfWeek = self?.viewModel.dayOfWeek else { return }
            self?.delegate?.showScheduleDetailScreen(startTime: startTime, day: dayOfWeek, tapedTimeline: true)
        }.disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSchedules()
    }
    
    private func updateSchedules() {
        SVProgressHUD.show()
        viewModel.getScheduleOfDay {
            SVProgressHUD.dismiss()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func needRefreshSchedules() {
       updateSchedules()
    }
    
    private func configurationSheetView() {
        NotificationCenter.default.addObserver(self, selector: #selector(needRefreshSchedules),
                                               name: .KLDNeedToUpdateSchedules, object: nil)
        self.schedulesView.translatesAutoresizingMaskIntoConstraints = false
        self.schedulesView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.schedulesView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.schedulesView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.schedulesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.schedulesView.isScrollEnabled = true
        
        schedulesView.dataSource = self
        schedulesView.delegate = self
        schedulesView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        schedulesView.intercellSpacing = CGSize(width: 0, height: 1)
        schedulesView.gridStyle = .none
        schedulesView.indicatorStyle = .white
        schedulesView.register(TimeCell.self, forCellWithReuseIdentifier: String(describing: TimeCell.self))
        schedulesView.register(ScheduleCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCell.self))
        addSmartScheduleButton.setTitle("ADD_SMARTSCHEDULE_TEXT".app_localized, for: .normal)
    }
}

extension TabContentViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.hoursData.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 100
        } else {
            return self.view.frame.width - 100 - 20
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 46
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let scheduleOfDayViewModel = viewModel.scheduleOfDayViewModel
        if case (0, 0...viewModel.hoursData.count - 1) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as! TimeCell
            cell.label.text = viewModel.hoursData[indexPath.row]
            return cell
        } else if indexPath.column == 1 && scheduleOfDayViewModel.startRowList.contains(indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as! ScheduleCell
            cell.backgroundView?.backgroundColor = UIColor.gray
            guard let blockSchedule = scheduleOfDayViewModel.displayData[indexPath.row] else {
                return cell
            }
            cell.scheduleContent = blockSchedule
            return cell
        }
        return nil
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return viewModel.mergeCellData
    }
    
    /// Delegate
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
        let hour = indexPath.row/2
        let minute = indexPath.row%2 == 0 ? 0 : 30
        if hour <= 23 {
            let startTime = Time(hour: hour, minute: minute)
            delegate?.showScheduleDetailScreen(startTime: startTime, day: viewModel.dayOfWeek, tapedTimeline: indexPath.column == 0 ? true : false)
        }
    }
}

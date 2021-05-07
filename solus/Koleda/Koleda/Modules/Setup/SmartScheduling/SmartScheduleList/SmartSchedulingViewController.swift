//
//  SmartSchedulingViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/22/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift


class SmartSchedulingViewController:  BaseViewController, BaseControllerProtocol {
    var viewModel: SmartSchedulingViewModelProtocol!
    private let disposeBag = DisposeBag()
    @IBOutlet weak var selectedDayLabel: UILabel!
    @IBOutlet weak var nextDayLabel: UILabel!
    @IBOutlet weak var daysView: UIView!
    @IBOutlet weak var swipeView: UIView!
    var scrollToNext: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        statusBarStyle(with: .lightContent)
        setTitleScreen(with: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SchedulingTabsViewController" {
            if let schedulingTabsViewController  = segue.destination as? SchedulingTabsViewController {
                schedulingTabsViewController.parentController = self
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
    @IBAction func swipeMade(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left && viewModel.currentSelectedIndex < DayOfWeek.days - 1 {
            self.scrollToNext?(true)
        }
        
        if sender.direction == .right && viewModel.currentSelectedIndex > 0 {
            self.scrollToNext?(false)
        }
    }
    
    private func configurationUI() {
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        leftRecognizer.direction = .left
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action:
            #selector(swipeMade(_:)))
        rightRecognizer.direction = .right
        self.swipeView.addGestureRecognizer(leftRecognizer)
        self.swipeView.addGestureRecognizer(rightRecognizer)
    }
    
    private func updateSelectedDay(selectedIndex: Int) {
        viewModel.currentSelectedIndex = selectedIndex
        self.selectedDayLabel.text =  DayOfWeek.dayWithIndex(index: selectedIndex).getStringLocalizeDay()
        if selectedIndex == DayOfWeek.days - 1 {
            self.nextDayLabel.text =  DayOfWeek.dayWithIndex(index: 0).getStringLocalizeDay()
        } else {
            self.nextDayLabel.text =  DayOfWeek.dayWithIndex(index: selectedIndex + 1).getStringLocalizeDay()
        }
    }
}

extension SmartSchedulingViewController: PageTabMenuViewControllerDelegate {
    func currentPageIndex(indexPage: Int) {
        updateSelectedDay(selectedIndex: indexPage)
    }
}

extension SmartSchedulingViewController: TabContentViewControllerDelegate {
    func showScheduleDetailScreen(startTime: Time, day: DayOfWeek, tapedTimeline: Bool) {
        self.viewModel.showScheduleDetail(startTime: startTime, day: day, tapedTimeline: tapedTimeline)
    }
}

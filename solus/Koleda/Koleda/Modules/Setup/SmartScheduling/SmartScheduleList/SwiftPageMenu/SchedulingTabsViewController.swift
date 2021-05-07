//
//  SchedulingTabsViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/30/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SpreadsheetView

class SchedulingTabsViewController: UIViewController {
    var parentController: SmartSchedulingViewController?
    var pageTabMenuViewController: PageTabMenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items =  [DayOfWeek.MONDAY.titleOfDay, DayOfWeek.TUESDAY.titleOfDay, DayOfWeek.WEDNESDAY.titleOfDay, DayOfWeek.THURSDAY.titleOfDay, DayOfWeek.FRIDAY.titleOfDay, DayOfWeek.SATURDAY.titleOfDay, DayOfWeek.SUNDAY.titleOfDay ]
        let pageTabMenuViewController = PageTabMenuViewController(titles: items, options: UnderlinePagerOption())
        pageTabMenuViewController.parentController = parentController
        self.addChild(pageTabMenuViewController)
        self.view.addSubview(pageTabMenuViewController.view)
        self.pageTabMenuViewController = pageTabMenuViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parentController = self.parentController, let pageController = self.pageTabMenuViewController {
            pageController.pageTabMenuDelegate = parentController
        }
    }
    
    private func getMergeCellData(rowsMergeData: [(startIndex: Int, numberRows: Int)]) -> [CellRange] {
        var mergeData: [CellRange] = []
        for data in rowsMergeData {
            if data.numberRows > 1 {
                let startRow = data.startIndex
                let endRow = (data.startIndex + data.numberRows) - 1
                
                mergeData.append(CellRange(from: (row: startRow, column: 1), to: (row: endRow, column: 1)))
            }
        }
        return mergeData
    }

}

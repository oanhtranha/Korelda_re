//
//  DynamicDataLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 18/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

class DynamicDataLogicModule: RafCellLogicModule {
    
    let dynamicData: DynamicData
    var dataSource: [DynamicItem] {
        return dynamicData.dynamicItems
    }
    
    init(dynamicData: DynamicData) {
        self.dynamicData = dynamicData
    }
    
    var dynamicDataTitle: String? {
        return dynamicData.title
    }
    
    var tableViewHeight: CGFloat {
        return 147.0 * CGFloat(dataSource.count)
    }
    
    var hasDynamicData: Bool {
        return !dataSource.isEmpty
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return DynamicContentsTableViewCell.stringFromClass()
        }
    }
    
    override func getEstimatedCellHeight() -> CGFloat {
        //Height changed
        return 300
    }
}

extension DynamicDataLogicModule: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var generalCell = UITableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: DynamicContentTableViewCell.stringFromClass(), for: indexPath) as? DynamicContentTableViewCell {
            
            let dynamicData = dataSource[indexPath.row]
            cell.set(title: dynamicData.title, imageURLString: dynamicData.imageUrl, description: dynamicData.description, auxiliaryText: dynamicData.auxiliaryText)
            
            cell.contentview.setShadow()
            generalCell = cell
        }
        
        return generalCell
    }
    
}

extension DynamicDataLogicModule: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let dynamicData = dataSource[indexPath.row]
        
        let rafTapDynamicContentItemAnalyticsEvent = RafTapDynamicContentItemAnalyticsEvent(dynamicItemTitle: dynamicData.title, dynamicItemActionUrl: dynamicData.actionUrl, dynamicItemPosition: indexPath.row)
        Copilot.instance.report.log(event: rafTapDynamicContentItemAnalyticsEvent)
        
        guard let actionUrl = dynamicData.actionUrl, let url = URL(string: actionUrl) else {
            return //Be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
}

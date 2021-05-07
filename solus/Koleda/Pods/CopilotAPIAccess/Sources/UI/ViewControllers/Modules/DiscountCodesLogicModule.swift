//
//  DiscountCodesLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

class DiscountCodesLogicModule: RafCellLogicModule {
    
    let dataSource: [DiscountCode]
    
    private let crutonPresentor = CrutonPresentor()
    
    init(discountCodes: [DiscountCode]) {
        dataSource = discountCodes
    }
    
    var hasDiscountCodes: Bool {
        return dataSource.isEmpty
    }
    
    var tableViewHeight: CGFloat {
        return 72 * CGFloat(dataSource.count)
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return DiscountCodesTableViewCell.stringFromClass()
        }
    }
    
    override func getEstimatedCellHeight() -> CGFloat {
        return 300
    }
}

extension DiscountCodesLogicModule: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var generalCell = UITableViewCell()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: DiscountCodeTableViewCell.stringFromClass(), for: indexPath) as? DiscountCodeTableViewCell {
            cell.delegate = self
            
            let discountCode = dataSource[indexPath.row]
            cell.set(value: discountCode.value, currency: discountCode.currencySymbol, code: discountCode.code)
            generalCell = cell
        }
        
        return generalCell
    }
    
}

extension DiscountCodesLogicModule: DiscountCodeTableViewCellDelegate {
    
    func showCruton() {
        crutonPresentor.presentCruton(with: CrutonModel(backgroundColor: .white, crutonHeight: 25, textString: "Copied!", textColor: .black, presentationPosition: .top))
    }
}

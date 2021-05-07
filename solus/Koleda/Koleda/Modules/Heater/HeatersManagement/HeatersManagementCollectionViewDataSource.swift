//
//  HeatersManagementCollectionViewDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 9/5/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Foundation

class HeatersManagementCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var heaters: [Heater]?
    var viewModel: HeatersManagementViewModelProtocol?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isEmpty(heaters) ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if !isEmpty(heaters) && section == 0 {
            return heaters!.count
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isEmpty(heaters) && indexPath.section == 0 {
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "HeaterManagementCollectionViewCell",
                                     for: indexPath) as? HeaterManagementCollectionViewCell, let heaters = heaters else {
                                        fatalError()
            }
            let heater = heaters[indexPath.row]
            cell.setup(with: heater)
            cell.removeHandler = { [weak self] heater in
                guard let `self` = self else {
                    return
                }
                self.viewModel?.removeHeater(by: heater)
            }
            return cell
        } else {
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "AddHeaterManagementCollectionViewCell",
                                     for: indexPath) as? AddHeaterManagementCollectionViewCell else {
                                        fatalError()
            }
            cell.addButton.rx.tap.bind { [weak self] in
                self?.viewModel?.addHeaterFlow()
            }
            cell.setup()

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        var title:UILabel? = headerView.viewWithTag(100) as? UILabel
        if !isEmpty(heaters) && indexPath.section == 0 {
            title?.text = "HEATERS_TEXT".app_localized
        } else {
            title?.text = "ADD_HEATERS_TEXT".app_localized
        }
        return headerView
    }
    
}


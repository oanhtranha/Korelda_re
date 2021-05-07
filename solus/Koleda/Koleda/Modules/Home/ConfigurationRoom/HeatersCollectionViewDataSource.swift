//
//  HeatersCollectionViewDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 8/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Foundation

class HeatersCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var heaters: [Heater]?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return heaters?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "HeaterCollectionViewCell",
                                 for: indexPath) as? HeaterCollectionViewCell, let heaters = heaters else {
                fatalError()
        }
        let heater = heaters[indexPath.section]
        cell.setup(with: heater)
        return cell
    }
    
}

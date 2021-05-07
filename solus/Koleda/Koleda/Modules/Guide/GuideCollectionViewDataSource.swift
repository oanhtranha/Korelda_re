//
//  GuideCollectionViewDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class GuideCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var guideItems: [GuideItem]?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return guideItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell",
                                 for: indexPath) as? GuideCollectionViewCell,
            let guidePages = guideItems else {
                fatalError()
        }
        let guidePage = guidePages[indexPath.section]
        cell.reloadPage(with: guidePage)
        return cell
    }
    
}

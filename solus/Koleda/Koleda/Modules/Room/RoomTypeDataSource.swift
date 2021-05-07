//
//  RoomTypeDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class RoomTypeDataSource: NSObject, UICollectionViewDataSource {
    
    var roomTypes: [RoomType]?
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return roomTypes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomTypeCell", for: indexPath) as? RoomTypeCell, let roomTypes = roomTypes else {
            fatalError()
        }
        let roomType = roomTypes[indexPath.item]
        cell.loadData(roomType: roomType)
        return cell
    }
    
}

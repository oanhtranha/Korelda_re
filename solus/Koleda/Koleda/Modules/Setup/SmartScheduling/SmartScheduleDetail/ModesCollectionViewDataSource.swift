//
//  ModesCollectionViewDataSource.swift
//  Koleda
//
//  Created by Oanh tran on 11/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ModesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var smartModes: [ModeItem] = []
    var selectedMode: ModeItem?
    var fromModifyModesScreen: Bool = false

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return smartModes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ScheduleModeCell",
                                 for: indexPath) as? ScheduleModeCell else {
                                    fatalError()
        }
        var isSelected: Bool = false
        let mode = smartModes[indexPath.section]
        if let selectedMode = selectedMode {
            isSelected = (mode.mode == selectedMode.mode)
        }
        cell.setup(with: mode, isSelected: isSelected, fromModifyModesScreen: fromModifyModesScreen)
        return cell
    }
}

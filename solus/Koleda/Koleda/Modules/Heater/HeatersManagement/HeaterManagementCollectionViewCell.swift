//
//  HeaterManagementCollectionViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 9/5/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class HeaterManagementCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var heaterImageView: UIImageView!
    @IBOutlet weak var heaterNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var removeHandler: ((Heater) -> Void)? = nil
    private let disposeBag = DisposeBag()
    func setup(with heater: Heater) {
        heaterNameLabel.text = heater.name
        if heater.enabled {
            statusLabel.text = "ACTIVE_TEXT".app_localized
            statusLabel.textColor = UIColor.green
        } else {
            statusLabel.text = "INACTIVE_TEXT".app_localized
            statusLabel.textColor =  UIColor.red
        }
        removeButton.rx.tap.bind {
            self.removeHandler?(heater)
        }.disposed(by: disposeBag)
        removeButton.setTitle("REMOVE_TEXT".app_localized, for: .normal)
    }
}

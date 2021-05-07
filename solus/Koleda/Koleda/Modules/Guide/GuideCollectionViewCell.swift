//
//  GuideCollectionViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class GuideCollectionViewCell: UICollectionViewCell , UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private var guideItem: GuideItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        let cellNib = UINib(nibName: GuideTableViewCell.get_identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: GuideTableViewCell.get_identifier)
    }
    
    func reloadPage(with guideItem: GuideItem) {
        self.guideItem = guideItem
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let guideItem = guideItem, let cell = tableView.dequeueReusableCell(withIdentifier: GuideTableViewCell.get_identifier, for: indexPath) as? GuideTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(with: guideItem)
        return cell
    }
}


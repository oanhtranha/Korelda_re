//
//  LegalViewController.swift
//  Koleda
//
//  Created by Oanh Tran on 11/8/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import RxSwift

class LegalViewController: BaseViewController, BaseControllerProtocol {
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var legalTitleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: LegalViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomTitleLabel.attributedText = "CONTACT_FOR_HELP_MESSAGE".app_localized.attributeText(normalSize: 16, boldSize: 16)
        tableView.reloadData()
        self.setupLabelTap()
    }
    
    @objc func contactTapped(_ sender: UITapGestureRecognizer) {
        print("contact Tapped")
    }
    
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.contactTapped(_:)))
        self.bottomTitleLabel.isUserInteractionEnabled = true
        self.bottomTitleLabel.addGestureRecognizer(labelTap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setTitleScreen(with: "")
        viewModel.viewWillAppear()
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
}

extension LegalViewController: UITableViewDelegate {
    
}

extension LegalViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LegalMenuCell.get_identifier, for: indexPath) as? LegalMenuCell else {
            log.error("Invalid cell type call")
            return UITableViewCell()
        }
        let title = viewModel.legalItems.value[indexPath.row]
        cell.setText(title: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedItem(index: indexPath.row)
    }
    
    
}

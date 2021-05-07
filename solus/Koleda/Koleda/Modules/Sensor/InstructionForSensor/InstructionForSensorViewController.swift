//
//  InstructionViewController.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class InstructionViewController:  BaseViewController, BaseControllerProtocol {
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    let router = InstructionForSensorRouter()
    var viewModel:InstructionViewModel!
    var counter = 0
    var roomId: String = ""
    var roomName: String = ""
    var isFromRoomConfiguration: Bool = false
    
    typealias ViewModelType = InstructionViewModel
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        statusBarStyle(with: .lightContent)
        viewModel = InstructionViewModel.init(router: self.router,typeInstructions: [.instructionForSensor1, .instructionForSensor2, .instructionForSensor3, .instructionForSensor4, .instructionForSensor5, .instructionForSensor6])
        router.baseViewController = self
        initView()
    }
    
    func initView() {
        pageView.numberOfPages = viewModel.typeInstructions.value.count
        pageView.currentPage = 0
    }

    @objc func changeImage() {
        if counter < viewModel.typeInstructions.value.count - 1 {
            let index = IndexPath.init(item: counter + 1, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter + 1
        } else {
            viewModel.nextToSensorManagement(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        counter = pageView.currentPage
        changeImage()
    }
    
    @IBAction func skipAction(_ sender: Any) {
        viewModel.nextToSensorManagement(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
    }
    
    @IBAction func backAction(_ sender: Any) {
        if isFromRoomConfiguration {
            back()
        } else {
            viewModel.backToRoot()
        }
    }
}

extension InstructionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.typeInstructions.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let instruction = cell.viewWithTag(1001) as? InstructionView {
            let type = viewModel.typeInstructions.value[indexPath.row]
            instruction.updateUI(type: type)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        counter = indexPath.row
        pageView.currentPage = counter
    }
}

extension InstructionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

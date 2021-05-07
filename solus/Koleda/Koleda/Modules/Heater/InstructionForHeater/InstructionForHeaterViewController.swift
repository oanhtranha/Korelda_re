//
//  InstructionForHeaterViewController.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class InstructionForHeaterViewController:  BaseViewController, BaseControllerProtocol {
    
    @IBOutlet weak var topPageControlConstraint: NSLayoutConstraint!
//    @IBOutlet weak var heighImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    let router = InstructionForHeaterRouter()
    var viewModel:InstructionForHeaterViewModel!
    var counter = 0
    var roomId: String = ""
    var roomName: String = ""
    var isFromRoomConfiguration: Bool = false
    
    typealias ViewModelType = InstructionForHeaterViewModel
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel = InstructionForHeaterViewModel.init(router: self.router, typeInstructions: [.instructionForHeater1, .instructionForHeater2, .instructionForHeater3, .instructionForHeater4])
        router.baseViewController = self
        initView()
    }
    
    func initView() {
        if UIDevice.screenType == .iPhones_5_5s_5c_SE {
            topPageControlConstraint.constant = 205
//            heighImageConstraint.constant = 275
        }
        pageView.numberOfPages = viewModel.typeInstructions.value.count
        pageView.currentPage = 0
        nextButton.setTitle("NEXT_TEXT".app_localized, for: .normal)
        skipButton.setTitle("SKIP_TEXT".app_localized, for: .normal)
    }

    @objc func changeImage() {
        if counter < viewModel.typeInstructions.value.count - 1 {
            let index = IndexPath.init(item: counter + 1, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter + 1
        } else {
            viewModel.nextToAddHeater(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        counter = pageView.currentPage
        changeImage()
    }
    
    @IBAction func skipAction(_ sender: Any) {
        viewModel.nextToAddHeater(roomId: roomId, roomName: roomName, isFromRoomConfiguration: isFromRoomConfiguration)
    }
    
    @IBAction func backAction(_ sender: Any) {
        if (isFromRoomConfiguration) {
            back()
        } else {
            viewModel.backToRoot()
        }
    }
}

extension InstructionForHeaterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

extension InstructionForHeaterViewController: UICollectionViewDelegateFlowLayout {
    
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

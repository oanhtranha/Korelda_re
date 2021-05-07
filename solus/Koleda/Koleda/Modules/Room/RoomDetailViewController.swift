//
//  RoomDetailViewController.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

class RoomDetailViewController: BaseViewController, BaseControllerProtocol, KeyboardAvoidable {
    @IBOutlet weak var roomNameTextField: AndroidStyle3TextField!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var widthCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomTypeCollectionView: UICollectionView!
    @IBOutlet weak var confirmRoomNameImageView: UIImageView!
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    
    var viewModel: RoomDetailViewModelProtocol!
    private let disposeBag = DisposeBag()
    private let itemsPerRow: CGFloat = 3
    private var selectedIndexPath: IndexPath?
    var keyboardHelper: KeyboardHepler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTransparency()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.viewWillAppear()
        addKeyboardObservers(forConstraints: [nextButtonConstraint])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
}

extension RoomDetailViewController {
    private func configurationUI() {
        keyboardHelper = KeyboardHepler(self)
        if UIDevice.screenType == .iPhones_5_5s_5c_SE {
            widthCollectionConstraint.constant = 242
        } else {
            widthCollectionConstraint.constant = 344
        }
        viewModel.screenTitle.asObservable().bind(to: screenTitleLabel.rx.text).disposed(by: disposeBag)
        viewModel.roomTypes.asObservable().subscribe(onNext: { [weak self] roomTypes in
            guard roomTypes.count > 0, let roomTypeDataSource = self?.roomTypeCollectionView.dataSource as? RoomTypeDataSource else { return }
            roomTypeDataSource.roomTypes = roomTypes
            self?.roomTypeCollectionView.reloadData()
        }).disposed(by: disposeBag)
        nextButton.rx.tap.bind { [weak self] in
            SVProgressHUD.show()
            self?.nextButton.isEnabled = false
            self?.viewModel.next(roomType: self?.viewModel.roomType(at: self?.selectedIndexPath), completion: {
                SVProgressHUD.dismiss()
                self?.nextButton.isEnabled = true
            })
        }.disposed(by: disposeBag)
        deleteButton.rx.tap.bind { [weak self] in
            self?.showDeletePopUp()
        }.disposed(by: disposeBag)
        viewModel.roomName.asObservable().bind(to: roomNameTextField.rx.text).disposed(by: disposeBag)
        roomNameTextField.rx.text.orEmpty.bind(to: viewModel.roomName).disposed(by: disposeBag)
        viewModel.roomName.asObservable().subscribe(onNext: { [weak self]  value in
            self?.confirmRoomNameImageView.isHidden = isEmpty(value)
        }).disposed(by: disposeBag)
        viewModel.selectedCategory.asObservable().subscribe(onNext: { [weak self] categoryString in
            guard let indexpath = self?.viewModel.indexPathOfCategory(with: categoryString) else { return }
            self?.selectedIndexPath = indexpath
            self?.roomTypeCollectionView.selectItem(at: indexpath, animated: true, scrollPosition: .bottom)
        }).disposed(by: disposeBag)
        viewModel.roomNameErrorMessage.asObservable().subscribe(onNext: { [weak self] message in
            self?.roomNameTextField.errorText = message
            if message.isEmpty {
                self?.roomNameTextField.showError(false)
            } else {
                self?.roomNameTextField.showError(true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.nextButtonTitle.asObservable().bind { [weak self] title in
            self?.nextButton.setTitle(String(format: "%@  ", title), for: .normal)
        }
        viewModel.showPopUpSelectRoomType.asObservable().subscribe(onNext: { [weak self]  show in
            self?.showPopUpRequireSelectRoomType()
        }).disposed(by: disposeBag)
        viewModel.showPopUpSuccess.asObservable().subscribe(onNext: { [weak self] show in
            self?.app_showInfoAlert("ADD_ROOM_SUCCESS_MESS".app_localized)
        }).disposed(by: disposeBag)
        viewModel.hideDeleteButton.asObservable().subscribe(onNext: {  [weak self]  show in
            self?.deleteButton.isHidden = show
        }).disposed(by: disposeBag)
        roomNameTextField.titleText = "ROOM_NAME_TEXT".app_localized
    }
    
    private func showDeletePopUp() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickLetfButton = {
                self.showConfirmPopUp()
            }
            if let image:UIImage = viewModel.currentRoomType?.homeImage, let roomName: String = viewModel.roomName.value {
                vc.typeAlert = .deleteRoom(icon: image, roomName: roomName)
            }
            showPopup(vc)
        }
    }
    
    private func showConfirmPopUp() {
        if let vc = getViewControler(withStoryboar: "Room", aClass: AlertConfirmViewController.self) {
            vc.onClickRightButton = {
                self.viewModel.deleteRoom()
            }
            vc.typeAlert = .confirmDeleteRoom
            showPopup(vc)
        }
    }
    
    private func showPopUpRequireSelectRoomType() {
        app_showAlertMessage(title: "ERROR_TITLE".app_localized, message: "PLEASE_SELECT_ROOM_TYPE".app_localized)
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
}
// MARK: - Collection View Flow Layout Delegate
extension RoomDetailViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.screenType == .iPhones_5_5s_5c_SE {
            return CGSize(width: 80, height: 80)
        } else {
            return CGSize(width: 114, height: 114)
        }
    }
}

extension RoomDetailViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath =  indexPath
    }
}

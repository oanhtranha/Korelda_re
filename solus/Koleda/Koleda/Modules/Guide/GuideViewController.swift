//
//  GuideViewController.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

class GuideViewController: BaseViewController, BaseControllerProtocol {

    var viewModel: GuideViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Style.Button.primary.apply(to: nextButton)
        viewModel.guideItems.asObservable().subscribe(onNext: { [weak self] guideItems in
            guard guideItems.count > 0, let guideCollectionViewDataSource = self?.collectionView.dataSource as? GuideCollectionViewDataSource else { return }
            guideCollectionViewDataSource.guideItems = guideItems
            self?.pageControl.numberOfPages =  guideItems.count
            self?.collectionView.reloadData()
            
        }).disposed(by: disposeBag)
        collectionView.isPagingEnabled = true
        nextButton.rx.tap.bind { [weak self] in
            self?.viewModel.next()
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        addCloseFunctionality()
    }
}


extension GuideViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
            let index = scrollView.contentOffset.x / witdh
            let roundedIndex = round(index)
            self.pageControl?.currentPage = Int(roundedIndex)
        }
    }
}

extension GuideViewController :  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

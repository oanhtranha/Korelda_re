//
//  PageTabMenuViewController.swift
//  Koleda
//
//  Created by Oanh tran on 10/30/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Swift_PageMenu

protocol PageTabMenuViewControllerDelegate: class {
    func currentPageIndex(indexPage: Int)
}

class PageTabMenuViewController: PageMenuController {
   
    let titles: [String]
    weak var pageTabMenuDelegate: PageTabMenuViewControllerDelegate?
    var parentController: SmartSchedulingViewController?
    var defaultIndexPage: Int = 0
    init(titles: [String], options: PageMenuOptions? = nil) {
        self.titles = titles
        super.init(options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        
        if options.layout == .layoutGuide && options.tabMenuPosition == .bottom {
            self.view.backgroundColor = Theme.mainColor
        } else {
            self.view.backgroundColor = .white
        }
        
        if self.options.tabMenuPosition == .custom {
            self.view.addSubview(self.tabMenuView)
            self.tabMenuView.translatesAutoresizingMaskIntoConstraints = false
            
            self.tabMenuView.heightAnchor.constraint(equalToConstant: self.options.menuItemSize.height).isActive = true
            self.tabMenuView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            self.tabMenuView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            if #available(iOS 11.0, *) {
                self.tabMenuView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                self.tabMenuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            }
        }
        
        self.delegate = self
        self.dataSource = self
        
        self.parentController?.scrollToNext = { [weak self] value in
            guard let `self` = self else {
                return
            }
            if value {
                self.scrollToNext(animated: true, completion: { _ in })
            } else {
                self.scrollToPrevious(animated: true, completion: { _ in })
            }
        }
        
    }
}

extension PageTabMenuViewController: PageMenuControllerDataSource {
    
    func viewControllers(forPageMenuController pageMenuController: PageMenuController) -> [UIViewController] {
        return self.titles.enumerated().map({ (i, title) -> UIViewController in
            let daySring = DayOfWeek.dayWithIndex(index: i)
            guard let viewController = TabContentViewController.instantiate(dayOfWeek: DayOfWeek.init(fromString: daySring.uppercased())) else {
                return UIViewController()
            }
            viewController.delegate = parentController
            return viewController
        })
    }
    
    func menuTitles(forPageMenuController pageMenuController: PageMenuController) -> [String] {
        return self.titles
    }
    
    func defaultPageIndex(forPageMenuController pageMenuController: PageMenuController) -> Int {
        let currentDay = Date().dayNumberOfWeek()
//        pageTabMenuDelegate?.currentPageIndex(indexPage: currentDay)
        parentController?.currentPageIndex(indexPage: currentDay)
        return currentDay
    }
}

extension PageTabMenuViewController: PageMenuControllerDelegate {
    
    func pageMenuController(_ pageMenuController: PageMenuController, didScrollToPageAtIndex index: Int, direction: PageMenuNavigationDirection) {
        // The page view controller will begin scrolling to a new page.
        print("didScrollToPageAtIndex index:\(index)")
        pageTabMenuDelegate?.currentPageIndex(indexPage: index)
    }
    
    func pageMenuController(_ pageMenuController: PageMenuController, willScrollToPageAtIndex index: Int, direction: PageMenuNavigationDirection) {
        // The page view controller scroll progress between pages.
        print("willScrollToPageAtIndex index:\(index)")
    }
    
    func pageMenuController(_ pageMenuController: PageMenuController, scrollingProgress progress: CGFloat, direction: PageMenuNavigationDirection) {
        // The page view controller did complete scroll to a new page.
        print("scrollingProgress progress: \(progress)")
    }
    
    func pageMenuController(_ pageMenuController: PageMenuController, didSelectMenuItem index: Int, direction: PageMenuNavigationDirection) {
        pageTabMenuDelegate?.currentPageIndex(indexPage: index)
        print("didSelectMenuItem index: \(index)")
    }
}

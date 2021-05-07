//
//  UIScrollView+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 6/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func app_scrollToBottom(animated: Bool = true) {
        if contentSize.height > bounds.size.height {
            let bottomOffset = CGPoint(x:0, y: contentSize.height - bounds.size.height)
            setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    func app_scrollToTop(animated: Bool = true) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: animated)
    }
}

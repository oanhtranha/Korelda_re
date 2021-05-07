//
//  UnderlinePagerOption.swift
//  Koleda
//
//  Created by Oanh tran on 10/30/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Swift_PageMenu

struct UnderlinePagerOption: PageMenuOptions {
    
    var isInfinite: Bool = false
    
    var menuItemSize: PageMenuItemSize {
        return .sizeToFit(minWidth: 40, height: 50)
    }
    
    var menuTitleColor: UIColor {
        return UIColor.white
    }
    
    var menuTitleSelectedColor: UIColor {
        return Theme.mainColor
    }
    
    var menuCursor: PageMenuCursor {
        return .underline(barColor: Theme.mainColor, height: 2)
    }
    
    var font: UIFont {
        return UIFont.app_FuturaPTDemi(ofSize: 9)
    }
    
    var menuItemMargin: CGFloat {
        return 8
    }
    
    var tabMenuBackgroundColor: UIColor {
        return UIColor.black
    }
    
    public init(isInfinite: Bool = false) {
        self.isInfinite = isInfinite
    }
}

struct Theme {
    static var mainColor = UIColor.orange
}

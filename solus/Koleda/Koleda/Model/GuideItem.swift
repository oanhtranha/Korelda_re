//
//  GuideItem.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

struct GuideItem {
    let image: UIImage?
    let title: String
    let message: String
    
    init(image: UIImage?, title: String, message: String) {
        self.image = image
        self.title = title
        self.message = message
    }
}

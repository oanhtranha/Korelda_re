//
//  String+Range.swift
//  Koleda
//
//  Created by Oanh tran on 6/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

extension String {
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

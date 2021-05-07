//
//  PopupRepresentable.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public protocol PopupRepresentable {
    var title: String? { get }
    var message: String { get }
}

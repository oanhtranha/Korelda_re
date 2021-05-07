//
//  ReferAFriendViewControllerDelegate.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public protocol ReferAFriendViewControllerDelegate: class {
    func referAFriendViewControllerDidUnauthorize(_ vc: ReferAFriendViewController)
}

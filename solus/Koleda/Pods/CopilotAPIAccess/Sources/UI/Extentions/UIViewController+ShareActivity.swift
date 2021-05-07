//
//  UIViewController+ShareActivity.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

internal extension UIViewController {
    
    func shareText(_ text: String) {
        let objectsToShare = [text] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

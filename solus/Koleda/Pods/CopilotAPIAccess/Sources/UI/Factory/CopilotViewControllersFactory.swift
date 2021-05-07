//
//  CopilotViewControllersFactory.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

struct CopilotViewControllersFactory {
    
    private struct StoryboardNames {
        static let raf = "Raf"
    }
    
    private struct identifiers {
        static let mainRafVCIdentifier = ReferAFriendViewController.stringFromClass()
        static let rafDataVCIdentifier = RafDataViewController.stringFromClass()
        static let altruisticVCIdentifier = AltruisticViewController.stringFromClass()
    }
    
    static func createControllerWithType(_ viewControllerType: ViewControllerType) -> UIViewController? {
        var storyboardName: String?
        var identifier: String?
        var viewController: UIViewController?
        
        switch viewControllerType {
        case .mainRaf:
            storyboardName = StoryboardNames.raf
            identifier = identifiers.mainRafVCIdentifier
        case .rafData:
            storyboardName = StoryboardNames.raf
            identifier = identifiers.rafDataVCIdentifier
        case .altruistic:
            storyboardName = StoryboardNames.raf
            identifier = identifiers.altruisticVCIdentifier
        }
        
        if let identifier = identifier, let storyboard = storyboardName {
            let storyBoard = UIStoryboard.init(name: storyboard, bundle: Bundle.init(for: TopRafTableViewCell.self))
            viewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        }
        
        return viewController
    }
}


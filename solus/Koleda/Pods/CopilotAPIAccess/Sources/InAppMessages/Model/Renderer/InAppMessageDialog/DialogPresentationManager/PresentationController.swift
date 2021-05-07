//
//  PresentationController.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/02/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation
import UIKit

final internal class PresentationController: UIPresentationController {


    override func presentationTransitionWillBegin() {
        
        guard let _ = containerView else { return }
    

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {

        guard let presentedView = presentedView else { return }

        presentedView.frame = frameOfPresentedViewInContainerView
    }

}

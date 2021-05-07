//
//  KeyboardHepler.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class KeyboardHepler {
    fileprivate var view: UIView?
    fileprivate var scrollView: UIScrollView?
    fileprivate var tabDismissKeyboard: UITapGestureRecognizer?
    init(_ scrollView: UIScrollView) {
        tabDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(KeyboardHepler.dismissKeyboard))
        view = scrollView.superview
        self.scrollView = scrollView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    init(vc: UIViewController, scrollView: UIScrollView) {
        tabDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(KeyboardHepler.dismissKeyboard))
        self.view = vc.view
        self.scrollView = scrollView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    init(_ viewController: UIViewController) {
        tabDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(KeyboardHepler.dismissKeyboard))
        self.view = viewController.view
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        self.view?.addGestureRecognizer(tabDismissKeyboard!)
        if self.scrollView == nil {
            return
        }
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue
        let keyboardFrameConvertedToViewFrame = self.scrollView?.superview?.convert(keyboardFrame!, from: nil)
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            let insetHeight = ((self.scrollView?.frame.height)! + (self.scrollView?.frame.origin.y)!) - (keyboardFrameConvertedToViewFrame?.origin.y)!
            self.scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
            self.scrollView?.scrollIndicatorInsets  = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
        }) { (complete) -> Void in
        }
        
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view?.removeGestureRecognizer(tabDismissKeyboard!)
        if self.scrollView == nil {
            return
        }
        let userInfo = (notification as NSNotification).userInfo as! Dictionary<String, AnyObject>
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(withDuration: animationDuration, delay: 0, options:options, animations: { () -> Void in
            self.scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.scrollView?.scrollIndicatorInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }) { (complete) -> Void in
        }
    }
    @objc func dismissKeyboard() {
        self.view?.endEditing(true)
    }
}

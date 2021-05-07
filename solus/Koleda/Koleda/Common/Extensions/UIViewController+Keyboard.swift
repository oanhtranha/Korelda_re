//
//  UIViewController+Keyboard.swift
//  Koleda
//
//  Created by Oanh tran on 6/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

protocol KeyboardAvoidable: class {
    /*
     Provide array of constraints, which should be adjusted to keyboard height value on its appear. After keyboard
     hidding, initial constants values will be applied.
     */
    func addKeyboardObservers(forConstraints constraints: [NSLayoutConstraint])
    
    /*
     Adding of custom action on keyboard appearance. Keyboard height will be transfered as a parameter.
     */
    func addKeyboardObservers(forCustomBlock block: @escaping (CGFloat) -> Void)
    
    func addKeyboardObservers(forConstraints constraints: [NSLayoutConstraint]?,
                              customBlock block: ((CGFloat) -> Void)?)
    
    func removeKeyboardObservers()
}

fileprivate var KeyboardShowObserverObjectKey: UInt8 = 1
fileprivate var KeyboardHideObserverObjectKey: UInt8 = 2
fileprivate var ConstraintsDictionaryKey: UInt8 = 3

extension KeyboardAvoidable where Self: UIViewController {
    
    private var keyboardShowObserverObject: NSObjectProtocol? {
        get {
            return objc_getAssociatedObject(self, &KeyboardShowObserverObjectKey) as? NSObjectProtocol
        }
        set {
            objc_setAssociatedObject(self, &KeyboardShowObserverObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var keyboardHideObserverObject: NSObjectProtocol? {
        get {
            return objc_getAssociatedObject(self, &KeyboardHideObserverObjectKey) as? NSObjectProtocol
        }
        set {
            objc_setAssociatedObject(self, &KeyboardHideObserverObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var constraintsAndValues: [NSLayoutConstraint: CGFloat]? {
        get {
            return objc_getAssociatedObject(self, &ConstraintsDictionaryKey) as? [NSLayoutConstraint: CGFloat]
        }
        set {
            objc_setAssociatedObject(self, &ConstraintsDictionaryKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Public methods
    
    func addKeyboardObservers(forConstraints constraints: [NSLayoutConstraint]) {
        addKeyboardObservers(forConstraints: constraints, customBlock: nil)
    }
    
    func addKeyboardObservers(forCustomBlock block: @escaping (CGFloat) -> Void) {
        addKeyboardObservers(forConstraints: nil, customBlock: block)
    }
    
    func addKeyboardObservers(forConstraints constraints: [NSLayoutConstraint]?,
                              customBlock block: ((CGFloat) -> Void)?)
    {
        removeKeyboardObservers()
        if let constraints = constraints {
            constraintsAndValues = constraints.reduce([NSLayoutConstraint: CGFloat]()) {
                (result, constraint) -> [NSLayoutConstraint: CGFloat] in
                
                var result = result
                result[constraint] = constraint.constant
                return result
            }
        }
        
        keyboardShowObserverObject = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                                                            object: nil,
                                                                            queue: nil)
        { [weak self] notification in
            guard let notificationParameters = self?.getKeyboardShowParameters(fromNotification: notification) else {
//                log.error("Cant extract keyboard notification parameters")
                return
            }
            
            if let block = block {
                block(notificationParameters.height)
                return
            }
            
            self?.animateLayout(parameters: notificationParameters, animations: {
                self?.constraintsAndValues?.forEach {
                    if #available(iOS 11.0, *) {
                        $0.key.constant = notificationParameters.height + $0.value - ( self?.view.safeAreaInsets.bottom ?? 0 )
                    } else {
                        $0.key.constant = notificationParameters.height + $0.value
                    }
                    
                }
            })
        }
        
        keyboardHideObserverObject = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                                            object: nil,
                                                                            queue: nil)
        { [weak self] notification in
            guard let notificationParameters = self?.getKeyboardShowParameters(fromNotification: notification) else {
//                log.error("Cant extract keyboard notification parameters")
                return
            }
            if let block = block {
                block(notificationParameters.height)
                return
            }
            
            self?.animateLayout(parameters: notificationParameters, animations: {
                self?.constraintsAndValues?.forEach {
                    $0.key.constant = $0.value
                }
            })
        }
    }
    
    func removeKeyboardObservers() {
        if let keyboardShowObserverObject = keyboardShowObserverObject {
            NotificationCenter.default.removeObserver(keyboardShowObserverObject)
        }
        if let keyboardHideObserverObject = keyboardHideObserverObject {
            NotificationCenter.default.removeObserver(keyboardHideObserverObject)
        }
        keyboardShowObserverObject = nil
        keyboardHideObserverObject = nil
        constraintsAndValues = nil
    }
    
    // MARK: - Private methods
    
    typealias KeyboardNotificationParameters = (height: CGFloat,
        duration: TimeInterval,
        animationOptions: UIView.AnimationOptions)
    
    private func getKeyboardShowParameters(fromNotification notification: Notification) -> KeyboardNotificationParameters? {
        guard let info = notification.userInfo,
            let heightValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let durationValue = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurveValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt  else
        {
            return nil
        }
        
        return (heightValue.size.height, durationValue, UIView.AnimationOptions(rawValue: animationCurveValue << 16))
    }
    
    private func animateLayout(parameters: KeyboardNotificationParameters, animations: @escaping () -> Void) {
        UIView.animate(withDuration: parameters.duration,
                       delay: 0,
                       options: [parameters.animationOptions, .beginFromCurrentState],
                       animations: {
                        animations()
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

protocol EditingEndable: class  {
    func endEditing()
}

extension EditingEndable where Self: UIViewController {
    func endEditing() {
        view.endEditing(true)
    }
    
}

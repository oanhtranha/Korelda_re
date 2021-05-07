//
//  NpsDialogViewController.swift
//  CopilotAPIAccess
//
//  Created by Elad on 17/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import UIKit

class NpsDialogViewController: UIViewController {
    
    var completion: ((String?) -> Void)?
    
    var npsView: NpsDialogView {
        return view as! NpsDialogView // swiftlint:disable:this force_cast
    }
    
    override func loadView() {
        super.loadView()
        view = NpsDialogView(frame: .zero)
        npsView.completion = {[weak self] (str) in
            self?.completion?(str)
        }
    }
}

extension NpsDialogViewController {
    // MARK: - Setter / Getter
    
    // MARK: Content
    
    var labelQuestionText: String {
        get {
            return npsView.labelQuestionText ?? ""
        }
        set {
            npsView.labelQuestionText = newValue
        }
    }
    
    var ctaBackgroundColor: UIColor {
        get { return npsView.ctaBackgroundColor ?? UIColor.white }
        set {
            npsView.ctaBackgroundColor = newValue
        }
    }
    
    var ctaTextColor: UIColor {
        get { return npsView.ctaTextColor ?? UIColor.black }
        set {
            npsView.ctaTextColor = newValue
        }
    }
    
    var bgColor: UIColor {
        get { return npsView.bgColor ?? UIColor.white }
        set {
            npsView.bgColor = newValue
        }
    }
    
    var textColorHex: UIColor {
        get { return npsView.textColorHex ?? UIColor.white }
        set {
            npsView.textColorHex = newValue
        }
    }
    
    var labelNotLikely: String {
        get {
            return npsView.labelNotLikely ?? ""
        }
        set {
            npsView.labelNotLikely = newValue
        }
    }
    
    var labelExtremelyLikely: String {
        get {
            return npsView.labelExtremelyLikely ?? ""
        }
        set {
            npsView.labelExtremelyLikely = newValue
        }
    }
    
    var labelAskMeAnotherTime: String {
        get {
            return npsView.labelAskMeAnotherTime ?? ""
        }
        set {
            npsView.labelAskMeAnotherTime = newValue
        }
    }
    
    var labelDone: String {
        get {
            return npsView.labelDone ?? ""
        }
        set {
            npsView.labelDone = newValue
        }
    }
    
    var labelThankYou: String {
        get {
            return npsView.labelThankYou ?? ""
        }
        set {
            npsView.labelThankYou = newValue
        }
    }
    
    var image: UIImage? {
        get { return npsView.image }
        set {
            npsView.image = newValue
        }
    }
    
}

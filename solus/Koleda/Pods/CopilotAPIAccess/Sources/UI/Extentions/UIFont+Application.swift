//
//  UIFont+Application.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit
import CopilotLogger

internal extension UIFont {
    
    class func SFProTextRegularFont(size: CGFloat) -> UIFont? {
        var font = UIFont(name: "SFProText-Regular", size: size)
        
        if (font == nil) {
            font = UIFont.systemFont(ofSize: size, weight: .regular)
            ZLogManagerWrapper.sharedInstance.logError(message:"Could not load SF-Pro-Text-Regular")
        }
        
        return font
    }
    
    class func SFProTextBoldFont(size: CGFloat) -> UIFont? {
        var font = UIFont(name: "SFProText-Bold", size: size)
        
        if (font == nil) {
            font = UIFont.systemFont(ofSize: size, weight: .bold)
            ZLogManagerWrapper.sharedInstance.logError(message:"Could not load SF-Pro-Text-Bold")
        }
        
        return font
    }
    
    class func SFProTextSemiboldFont(size: CGFloat) -> UIFont? {
        var font = UIFont(name: "SFProText-Semibold", size: size)
        
        if (font == nil) {
            font = UIFont.systemFont(ofSize: size, weight: .semibold)
            ZLogManagerWrapper.sharedInstance.logError(message:"Could not load SF-Pro-Text-Bold")
        }
        
        return font
    }
    
    static func registerFontWith(filenameString: String) {
        _ = UIFont()
        if let frameworkBundle = Bundle(for: Copilot.self) as? Bundle {
            if frameworkBundle.isLoaded { frameworkBundle.load() }
            if let resourceBundlePath = frameworkBundle.path(forResource: filenameString, ofType: "otf") {
                if let fontData = NSData(contentsOfFile: resourceBundlePath), let dataProvider = CGDataProvider.init(data: fontData) {
                    if let fontRef = CGFont.init(dataProvider) {
                        var errorRef: Unmanaged<CFError>? = nil
                        if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {
                            ZLogManagerWrapper.sharedInstance.logError(message: "Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
                        }
                    }
                }
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "Failed to register font - bundle identifier invalid.")
            }
        }
    }
}


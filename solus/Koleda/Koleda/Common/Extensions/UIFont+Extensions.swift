//
//  UIFont+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 5/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//
import UIKit

extension UIFont {
    
    static func app_FuturaPTDemi(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "FuturaPT-Demi", size: size)!
    }
    
    static func app_FuturaPTBook(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "FuturaPT-Book", size: size)!
    }
    
    static func app_FuturaPTHeavy(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "FuturaPT-Heavy", size: size)!
    }
    
    static func app_FuturaPTLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "FuturaPT-Light", size: size)!
    }
    static func app_FuturaPTMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "FuturaPT-Medium", size: size)!
    }
    
    static func app_SFProDisplaySemibold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: size)!
    }
    
    static func app_SFProDisplayRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Regular", size: size)!
    }
    
    static func app_SFProDisplayMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size)!
    }
    
    static func SFProDisplayRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Regular", size: size)!
    }
    
    public static let SFProDisplaySemibold10: UIFont = UIFont(name: "SFProDisplay-Semibold", size: 10)!
    public static let SFProDisplaySemibold14: UIFont = UIFont(name: "SFProDisplay-Semibold", size: 14)!
    public static let SFProDisplaySemibold20: UIFont = app_SFProDisplaySemibold(ofSize: 20)
    public static let SFProDisplayRegular17: UIFont = UIFont(name: "SFProDisplay-Regular", size: 17)!
}

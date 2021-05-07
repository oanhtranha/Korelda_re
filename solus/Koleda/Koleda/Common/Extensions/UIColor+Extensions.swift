//
//  UIColor+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 5/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    
    struct RGBA {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
    
    convenience init(rgba: RGBA) {
        self.init(red: rgba.red,
                  green: rgba.green,
                  blue: rgba.blue,
                  alpha: rgba.alpha)
    }
    
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = (hex) & 0xFF
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    class var app_titleColor: UIColor {
        return UIColor.black
    }
    
    class var app_contentColor: UIColor {
        return UIColor.gray
    }
    
    public static let lightLine = UIColor(hex: 0xEAEAEA)
    public static let hexB5B5B5 = UIColor(hex: 0xB5B5B5)
    public static let hex53565A = UIColor(hex: 0x53565A)
    public static let hex1F1B15 = UIColor(hex: 0x1F1B15)
    public static let hexFF7020 = UIColor(hex: 0xFF7020)
    public static let hex88FFFFFF = UIColor(hex: 0xFFFFFF, alpha: 0.5)
    public static let hex44FFFFFF = UIColor(hex: 0xFFFFFF, alpha: 0.25)
    public static let hex7e7d80 = UIColor(hex: 0x7e7d80)
    
    public static let purpleLight = UIColor(hex: 0x496CE7)
    public static let greenLight = UIColor(hex: 0x20DBAE)
    public static let redLight = UIColor(hex: 0xFF8589)
    public static let yellowLight = UIColor(hex: 0xFFCF25)
    public static let blueLight = UIColor(hex: 0x97E0FF)
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
   
}



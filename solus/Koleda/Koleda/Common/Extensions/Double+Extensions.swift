//
//  Double+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 8/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

extension Double {
    func integerPart() -> Int {
        let numberString = String(self)
        let numberComponent = numberString.components(separatedBy :".")
        return Int(numberComponent [0]) ?? 0
    }
    
    func fractionalPart() -> Int {
        let numberString = String(self)
        let numberComponent = numberString.components(separatedBy :".")
        guard numberComponent.count == 2 else {
            return 0
        }
        return Int(numberComponent [1]) ?? 0
    }
    
    var fahrenheitTemperature: Double {
        let fValue = self*1.8 + 32
        return fValue.rounded()
    }
    
    var celciusTemperature: Double {
        let cValue = (self - 32)/1.8
        return cValue.roundToDecimal(1)
    }
    
    static func valueOf(clusterValue: (Int, Int) ) -> Double {
        return Double(clusterValue.0) +  Double(clusterValue.1) * 0.1
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func toString(fractionDigits: Int = 1) -> String {
        
        return String(format: "%.\(fractionDigits)f",self)
    }
	
	func currencyFormatter() -> String {
		let cf = NumberFormatter()
		cf.numberStyle = .decimal
		cf.maximumFractionDigits = 2
		cf.minimumFractionDigits = 2
		cf.locale = Locale(identifier: "en_US")
		cf.decimalSeparator = "."
		cf.groupingSeparator = ","
		return cf.string(for: self) ?? "0.0"
	}
}

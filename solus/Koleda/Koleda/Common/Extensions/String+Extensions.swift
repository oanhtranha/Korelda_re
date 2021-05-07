
//
//  String+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 6/18/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import SwiftRichString

public func isEmpty(_ obj: Any?) -> Bool {
    if obj == nil {
        return true
    } else if ((obj as? String) != nil) {
        return (obj as? String)!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    } else if ((obj as? Array<Any>) != nil) {
        return (obj as? Array<Any>)!.count == 0
    }  else if ((obj as? NSDictionary) != nil) {
        return (obj as? NSDictionary)!.count == 0
    } else {
        return false
    }
}

extension String {
    
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
    
    var app_localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var extraWhitespacesRemoved: String {
        let text = self.trimmingCharacters(in: .whitespaces)
        var result = ""
        
        let whitespace = " "
        var previousChar = whitespace
        
        for enumeratedChar in text {
            let enumeratedString = String(enumeratedChar)
            if !(previousChar == whitespace && enumeratedString == previousChar) {
                result.append(enumeratedString)
            }
            previousChar = enumeratedString
        }
        
        return result
    }
    
    var fahrenheitTemperature: String {
        guard let celsiusTemp = self.kld_doubleValue else {
            return "0"
        }
        let fValue = (celsiusTemp*1.8 + 32).roundToDecimal(1)
        return "\(fValue)"
    }
    
    var correctLocalTimeStringFormatForDisplay: String {
        if self == "23:59:59.999" {
            return "24:00:00"
        } else if self == "23:59:00" {
           return "24:00:00"
        }
        return self
    }
    
    var correctLocalTimeStringFormatForService: String {
        if self == "24:00:00" {
            return "00:00:00"
        }
        return self
    }
    
    func removingOccurances(_ stringsToRemove:[String]) -> String {
        var result = self
        stringsToRemove.forEach { enumeratedString in
            result = result.replacingOccurrences(of: enumeratedString, with: "")
        }
        
        return result
    }
    
    func timeValue() -> Time? {
        guard self.extraWhitespacesRemoved.count > 0 else {
            return nil
        }
        let arrayTime = self.components(separatedBy: ":")
        guard arrayTime.count == 2 else {
            return nil
        }
        let hour = (arrayTime[0] as NSString).integerValue
        let minute = (arrayTime[1] as NSString).integerValue
        return Time(hour: hour, minute: minute)
    }
    
    func removeSecondOfTime() -> String {
        guard self.extraWhitespacesRemoved.count > 0 else {
            return ""
        }
        let arrayTime = self.components(separatedBy: ":")
        guard arrayTime.count == 3 else {
            return self
        }
        return "\(arrayTime[0]) : \(arrayTime[1])"
    }
    
    func kld_localTimeFormat() -> String {
        return self.removingOccurances([" "]) + ":00"
    }
    
    func app_removePortInUrl() -> String {
        guard self.extraWhitespacesRemoved.count > 0 else {
            return ""
        }
        let arrayString = self.components(separatedBy: ":")
        guard arrayString.count == 2 else {
            return self
        }
        return arrayString[0].replacingOccurrences(of: "[", with: "")
    }
    
    func attributeText(normalSize: CGFloat, boldSize: CGFloat) -> NSAttributedString {
        let normal = SwiftRichString.Style{
            $0.font = UIFont.app_SFProDisplayRegular(ofSize: normalSize)
            $0.color = UIColor.lightGray
        }
        
        let bold = SwiftRichString.Style {
            $0.font = UIFont.app_SFProDisplayRegular(ofSize: boldSize)
            $0.color = UIColor.orange
        }
        
        let group = StyleGroup(base: normal, ["h1": bold])
        return self.set(style: group)
    }
    
    var kld_doubleValue: Double? {
        return Double(self)
    }
    
    var intValueWithLocalTime: Int? {
        return self.removeSecondOfTime().timeValue()?.timeIntValue()
    }
    
    func kld_getCurrencySymbol() -> String {
        var candidates: [String] = []
        let locales: [String] = NSLocale.availableLocaleIdentifiers
        for localeID in locales {
            guard let symbol = findMatchingSymbol(localeID: localeID, currencyCode: self) else {
                continue
            }
            if symbol.count == 1 {
                return symbol
            }
            candidates.append(symbol)
        }
        let sorted = sortAscByLength(list: candidates)
        if sorted.count < 1 {
            return ""
        }
        return sorted[0]
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    private func findMatchingSymbol(localeID: String, currencyCode: String) -> String? {
		let locale = Locale(identifier: localeID as String)
        guard let code = locale.currencyCode else {
            return nil
        }
        if code != currencyCode {
            return nil
        }
        guard let symbol = locale.currencySymbol else {
            return nil
        }
        return symbol
    }
    
    private func sortAscByLength(list: [String]) -> [String] {
        return list.sorted(by: { $0.count < $1.count })
    }
    
    func getStringLocalizeDay() -> String {
        switch self.uppercased() {
        case "MONDAY":
            return "MON_TEXT".app_localized
        case "TUESDAY":
            return "TUE_TEXT".app_localized
        case "WEDNESDAY":
            return "WED_TEXT".app_localized
        case "THURSDAY":
            return "THU_TEXT".app_localized
        case "FRIDAY":
            return "FRI_TEXT".app_localized
        case "SATURDAY":
            return "SAT_TEXT".app_localized
        default:
            return "SUN_TEXT".app_localized
        }
    }
}



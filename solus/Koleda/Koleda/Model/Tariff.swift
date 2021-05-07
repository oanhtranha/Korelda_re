//
//  Tariff.swift
//  Koleda
//
//  Created by Oanh tran on 8/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

struct Tariff: Codable {
    let dayTimeStart: String
    let dayTimeEnd: String
    let dayTariff: Double
    let nightTimeStart: String
    let nightTimeEnd: String
    let nightTariff: Double
    let currency: String
    
    init(dayTimeStart: String, dayTimeEnd: String, dayTariff: Double, nightTimeStart: String, nightTimeEnd: String, nightTariff: Double, currency: String) {
        self.dayTimeStart = dayTimeStart
        self.dayTimeEnd = dayTimeEnd
        self.dayTariff = dayTariff
        self.nightTimeStart = nightTimeStart
        self.nightTimeEnd = nightTimeEnd
        self.nightTariff = nightTariff
        self.currency = currency
    }
    
    private enum CodingKeys: String, CodingKey {
        case dayTimeStart
        case dayTimeEnd
        case dayTariff
        case nightTimeStart
        case nightTimeEnd
        case nightTariff
        case currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dayTimeStart = try container.decode(String.self, forKey: .dayTimeStart).removeSecondOfTime()
        self.dayTimeEnd = try container.decode(String.self, forKey: .dayTimeEnd).removeSecondOfTime()
        self.dayTariff = try container.decode(Double.self, forKey: .dayTariff)
        self.nightTimeStart = try container.decode(String.self, forKey: .nightTimeStart).removeSecondOfTime()
        self.nightTimeEnd = try container.decode(String.self, forKey: .nightTimeEnd).removeSecondOfTime()
        self.nightTariff = try container.decode(Double.self, forKey: .nightTariff)
        self.currency = try container.decode(String.self, forKey: .currency)
    }
}

struct ConsumeEneryTariff {
    let energyConsumedMonth: Double
    let energyConsumedWeek: Double
    let energyConsumedDay: Double
    
    init(energyConsumedMonth: Double, energyConsumedWeek: Double, energyConsumedDay: Double) {
        self.energyConsumedMonth = energyConsumedMonth
        self.energyConsumedWeek = energyConsumedWeek
        self.energyConsumedDay = energyConsumedDay
    }
}



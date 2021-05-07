//
//  User.swift
//  Koleda
//
//  Created by Oanh tran on 7/15/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

enum UserType: String{
	case Master  = "MASTER"
	case Guest = "GUEST"
	case Undefine = "UNDEFINE"
	case unknow
	
	init(fromString string: String) {
		guard let value = UserType(rawValue: string) else {
			self = .unknow
			return
		}
		self = value
	}
}

struct User: Codable {
    let id: String
    let name: String
    let email: String?
    let emailVerified: Bool?
    let imageUrl: String?
    let provider: String?
    let providerId: String?
    let temperatureUnit: String?
	let userType: String?
	var homes: [Home]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case emailVerified
        case imageUrl
        case provider
        case providerId
        case temperatureUnit
		case userType
		case homes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.emailVerified = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.provider = try container.decodeIfPresent(String.self, forKey: .provider)
        self.providerId = try container.decodeIfPresent(String.self, forKey: .providerId)
        self.temperatureUnit = try container.decodeIfPresent(String.self, forKey: .temperatureUnit)
		self.userType = try container.decodeIfPresent(String.self, forKey: .userType)
		self.homes = try container.decode([Home].self, forKey: .homes)
    }
}


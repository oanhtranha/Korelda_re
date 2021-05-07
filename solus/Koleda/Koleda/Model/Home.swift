//
//  Home.swift
//  Koleda
//
//  Created by Oanh Tran on 6/19/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation

struct Home: Codable {
	let id: String
	let name: String
	
	private enum CodingKeys: String, CodingKey {
		case id
		case name
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
	}
}
extension Home {
	init(json: [String: Any]) {
		id = json["id"] as? String ?? ""
		name = json["name"] as? String ?? ""
	}
}


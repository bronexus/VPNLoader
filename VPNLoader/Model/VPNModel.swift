//
//  VPNModel.swift
//  VPNLoader
//
//  Created by Dumitru on 27.03.2022.
//

import Foundation

struct VPNServerElement: Codable {
	
	let hostname: String
	let isFree: Bool
	let countryCode, location, country, name: String
	let serverID: Int
	let psk: String
	
}



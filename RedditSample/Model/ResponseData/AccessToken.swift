//
//  AccessToken.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 30.09.2020.
//

import Foundation

struct AccessToken: Deserializable {
	
	let token: String
	let refreshToken: String?
	
	init?(jsonDict: JSONDict) throws {
		token = jsonDict["access_token"] as! String
		refreshToken = jsonDict["refresh_token"] as? String
	}
	
}

//
//  AccessToken.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 30.09.2020.
//

import Foundation

struct AccessToken: ResponseData {
	
	let token: String
	let refreshToken: String
//	let type: String
//	let expiresIn: TimeInterval
//	let scope: String
	
	init?(jsonDict: JSONDict) throws {
		token = jsonDict["access_token"] as! String
		refreshToken = jsonDict["refresh_token"] as! String	
	}
	
}

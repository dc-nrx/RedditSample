//
//  ResponseData.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

protocol Deserializable {
	
	init?(jsonData: Data) throws
	init?(jsonDict: JSONDict) throws

}

extension Deserializable {
	
	init?(jsonData: Data) throws {
		let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
		guard let jsonDict = jsonObject as? JSONDict else {
			throw NetworkError.unexpectedResponseObject
		}
		
		try self.init(jsonDict: jsonDict)
	}
	
}

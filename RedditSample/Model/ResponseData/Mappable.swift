//
//  Serializable.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 06.10.2020.
//

import Foundation

typealias Mappable = Deserializable & Serializable

//MARK:-
protocol Serializable {
	
	var json: JSONDict { get }
}

//MARK:-
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

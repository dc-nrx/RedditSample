//
//  ResponseData.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

typealias JSONDict = [String: Any]


//MARK:- Error
enum ResponseDataError: Error {
	
	case unexpectedResponseObject(Any)
	
}

extension ResponseDataError: LocalizedError {
	
	var errorDescription: String? {
		switch self {
		case .unexpectedResponseObject:
			return NSLocalizedString("Unexpected response object received", comment: "")
		}
	}
	
}

///
/// Response Data
///
protocol ResponseData {
	
	init?(jsonData: Data) throws
	init?(jsonDict: JSONDict) throws
	
}

extension ResponseData {
	
	init?(jsonData: Data) throws {
		let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
		guard let jsonDict = jsonObject as? JSONDict else {
			throw ResponseDataError.unexpectedResponseObject(jsonObject)
		}
		
		try self.init(jsonDict: jsonDict)
	}
	
}

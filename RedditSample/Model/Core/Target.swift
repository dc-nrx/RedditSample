//
//  Service.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

///
/// A full configuration for a REST API service (inspired by Moya framework; simplified)
///
protocol Target {
	
	///
	/// Http header entries
	///
	var httpHeader: [String: String] { get }
	
	///
	/// The base URL to append the `path` to.
	///
	var baseURLString: String { get }

	///
	/// The path to the corresponding endpoint
	///
	var path: String { get }
	
	///
	/// The request method (get / post / ...)
	///
	var method: RequestMethod { get }
	
	///
	/// An optional body of the request
	///
	var body: Data? { get }
	
	//MARK:- Helpers
	// (Have default implementations)
	
	///
	/// An actual URL to send the request ( = `baseURLString` + `path`)
	///
	var url: URL { get }
	
	///
	/// A cocoa request generated from `self` to use with URLSession
	///
	var urlRequest: URLRequest { get }
}

//MARK:- Convenience
extension Target {
	
	var url: URL {
		// Intentional force unwrap (same logic as with outlets)
		URL(string: baseURLString.appending(path))!
	}
	
	var urlRequest: URLRequest {
		var result = URLRequest(url: url)
		result.httpBody = body
		result.allHTTPHeaderFields = httpHeader
		switch method {
		case .get:
			result.httpMethod = "GET"
		case .post:
			result.httpMethod = "POST"
		}
		return result
	}
}

enum RequestMethod: String {
	case get = "GET"
	case post = "POST"
}

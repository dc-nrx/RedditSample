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
	var httpHeaders: [String: String] { get }
	
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
	
	///
	/// Optional query items
	///
	var query: [URLQueryItem]? { get }
	
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
		let noParameterUrlString = baseURLString.appending(path)
		// Intentional force unwrap (same logic as with outlets)
		var components = URLComponents(string: noParameterUrlString)!
		components.queryItems = query
		components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
		return components.url!
	}
	
	var urlRequest: URLRequest {
		var result = URLRequest(url: url)
		result.httpBody = body
		result.allHTTPHeaderFields = httpHeaders
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

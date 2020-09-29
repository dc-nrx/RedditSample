//
//  Service.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

protocol Target {
	
	associatedtype ResponseType

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
	/// An actual URL to send the request ( = `baseURLString` + `path`)
	///
	var url: URL { get }
}

//MARK:- Convenience
extension Target {
	
	var url: URL {
		// Intentional force unwrap (same logic as with outlets)
		URL(string: baseURLString.appending(path))!
	}
	
}

enum RequestMethod: String {
	case get = "GET"
	case post = "POST"
}

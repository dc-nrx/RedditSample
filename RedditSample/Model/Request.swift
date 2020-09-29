//
//  Service.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

protocol Request {
	
	associatedtype ResponseType
	
	var method: RequstMethod { get }
	var baseURLString: String { get }
	var path: String { get }
	
}

enum RequstMethod: String {
	case GET = "GET"
	case POST = "POST"
}

//
//  Reddit.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

///
/// Reddit API: full request list & corresponding configurations. (inspired by Moya framework)
///
enum Reddit: Target {
	
	typealias ResponseType = Any
	
	case topFeed
	
}

//MARK:- Core
extension Reddit {
	
	///
	/// The app-specific api key required for OAuth
	///
	var apiKey: String { "111" }
	
	var baseURLString: String { "https://www.reddit.com/dev/" }
	
	var url: URL {
		// Intentional force unwrap (same logic as with outlets)
		URL(string: baseURLString.appending(path))!
	}
}

//MARK:- Path
extension Reddit {
	
	var path: String {
		switch self {
		case .topFeed:
			return "topFeed"
		}
	}
	
}

//MARK:- Method
extension Reddit {
	
	var method: RequestMethod {
		switch self {
		case .topFeed:
			return .get
		}
	}
	
}

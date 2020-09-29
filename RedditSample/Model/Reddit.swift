//
//  Reddit.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

///
/// A full configuration for the Reddit API
///
enum Reddit {
	
	case topFeed
}

//MARK:- Core
extension Reddit {
	
	///
	/// The app-specific api key required for OAuth
	///
	var apiKey: String { "111" }
	
	var baseURLString: String { "https://www.reddit.com/dev/" }
	
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

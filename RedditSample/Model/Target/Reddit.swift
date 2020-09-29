//
//  Reddit.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

///
/// Reddit API: full request list & corresponding configurations.
///
enum Reddit {
	
	case topFeed
	
	///
	/// The app secret key required for OAuth
	///
	var apiSecret: String { "GVsX6FPK1N9JDw" }
}

extension Reddit: Target {
		
	var baseURLString: String { "https://www.reddit.com/dev/" }
			
	var path: String {
		switch self {
		case .topFeed:
			return "topFeed"
		}
	}
	
	var method: RequestMethod {
		switch self {
		case .topFeed:
			return .get
		}
	}
	
}


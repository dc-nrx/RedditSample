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
	/// Tells reddit.com which app is making the request
	///
	static var clientId: String { "GVsX6FPK1N9JDw" }
	
	///
	/// Must be exactly the same as in the reddit app settings. Used only to make the initial oath request.
	///
	static var redirectURIString: String { "https://google.com" }
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


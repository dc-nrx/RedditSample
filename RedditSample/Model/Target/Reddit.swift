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
	
	case accessToken(code: Int, redirectURIString: String)
	case topFeed
	
	///
	/// Tells reddit.com which app is making the request
	///
	static var clientId: String { "GVsX6FPK1N9JDw" }
	
	///
	/// Must be exactly the same as in the reddit app settings. Used only to make the initial oath request.
	///
	static var redirectURIString: String { "https://google.com" }
	
	///
	/// Needed to add contact info to the requests header (being specific, to the `User-Agent` entry)
	/// as required by Reddit
	///
	static var ownerName: String { "dc_-_-" }
}

extension Reddit: Target {
		
	var httpHeader: [String : String] {
		let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
		var result = [
			"User-Agent": "iOS:\(Bundle.main.bundleIdentifier!):\(appVersion) (by /u/\(Reddit.ownerName))"
		]
		
		if let token = RedditSession.shared.accessToken {
			result["Authorization"] = "bearer \(token)"
		}
		
		return result
	}
	
	var baseURLString: String {
		switch self {
		case .accessToken:
			return "https://www.reddit.com/dev/"
		default:
			return "https://oauth.reddit.com/dev/"
		}
	}
			
	var path: String {
		switch self {
		case .accessToken:
			return "v1/access_token"
		case .topFeed:
			return "v1/topFeed"
		}
	}
	
	var method: RequestMethod {
		switch self {
		case .accessToken:
			return .post
		case .topFeed:
			return .get
		}
	}
	
	var body: Data? {
		switch self {
		case let .accessToken(code, redirectURIString):
			let str = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURIString)"
			return str.data(using: .utf8)
		default:
			return nil
		}
	}
}


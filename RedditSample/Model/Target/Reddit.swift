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
	
	case accessToken(grantType:String?, code: String?, refreshToken: String?)
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
		
		if let token = RedditSession.shared.accessToken.value {
			result["Authorization"] = "bearer \(token)"
		}
		else {
			let str = "\(Reddit.clientId):"
			let utf8str = str.data(using: .utf8)
			let base64 = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
			result["Authorization"] = "Basic \(base64!))"
		}
		
		return result
	}
	
	var baseURLString: String {
		switch self {
		case .accessToken:
			return "https://www.reddit.com/"
		default:
			return "https://oauth.reddit.com/"
		}
	}
			
	var path: String {
		switch self {
		case .accessToken:
			return "api/v1/access_token"
		case .topFeed:
			return "top"
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
		
		case let .accessToken(code):
			let str = "grant_type=authorization_code&code=\(code)&redirect_uri=\(Reddit.redirectURIString)"
			return str.data(using: .utf8)
			
		default:
			return nil
		}
	}
}


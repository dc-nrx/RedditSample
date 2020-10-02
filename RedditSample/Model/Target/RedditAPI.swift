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
enum RedditAPI {
	
	case accessToken(grantType:String, code: String?, refreshToken: String?)
	case topFeed(after: String?, limit: UInt?)
	
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

extension RedditAPI: Target {
		
	var httpHeader: [String : String] {
		// Standard headers
		let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
		var result = [
			"User-Agent": "iOS:\(Bundle.main.bundleIdentifier!):\(appVersion) (by /u/\(RedditAPI.ownerName))"
		]
		
		// Authrization
		switch self {
		case .accessToken:
			// Special case for access token (basic auth)
			let str = "\(RedditAPI.clientId):"
			let utf8str = str.data(using: .utf8)
			let base64 = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
			result["Authorization"] = "Basic \(base64!))"
		default:
			// Regular for others (via token)
			if let token = RedditSession.shared.accessToken.value {
				result["Authorization"] = "bearer \(token)"
			}
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
	
//	var queryParams:
	
	var body: Data? {
		switch self {
		
		case let .accessToken(grantType, code, refreshToken):
			var str = "grant_type=\(grantType)"
			if let code = code {
				str.append("&code=\(code)")
			}
			if let refreshToken = refreshToken {
				str.append("&refresh_token=\(refreshToken)")
			}
			str.append("&redirect_uri=\(RedditAPI.redirectURIString)")
			return str.data(using: .utf8)
			
		default:
			return nil
		}
	}
}


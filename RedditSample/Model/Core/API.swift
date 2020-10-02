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
enum API {
	
	///
	/// Used either to get (with a `code`) or refresh (with a `refreshToken`) the access token.
	/// - Parameter grantType: "refresh_token" if `refreshToken` != nil;
	/// authorization_code if `code` != nil
	/// - Parameter code: Authorization code retrieved after OAuth.
	/// - Parameter refreshToken: Refresh token.
	/// - Returns: `AccessToken`.
	///
	case accessToken(grantType:String, code: String?, refreshToken: String?)
	
	///
	/// The top listing listing
	/// - Parameter afterFullname: The listing item's fullname to get items after
	/// - Parameter limit: Number of items in response. Must be in 0...100. The default value is 25.
	/// - Returns: `Listing<Link>`
	///
	case topFeed(afterFullname: String?, limit: UInt?)
	
}

//MARK:- Settings
extension API {

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

extension API: Target {
		
	var httpHeader: [String : String] {
		// Standard headers
		let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
		var result = [
			"User-Agent": "iOS:\(Bundle.main.bundleIdentifier!):\(appVersion) (by /u/\(API.ownerName))"
		]
		
		// Authrization
		switch self {
		case .accessToken:
			// Special case for access token (basic auth)
			let str = "\(API.clientId):"
			let utf8str = str.data(using: .utf8)
			let base64 = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
			result["Authorization"] = "Basic \(base64!))"
		default:
			// Regular for others (via token)
			if let token = Session.shared.token.value {
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
			str.append("&redirect_uri=\(API.redirectURIString)")
			return str.data(using: .utf8)
			
		default:
			return nil
		}
	}
}


//
//  RedditSession.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation

///
/// Contains data required for OAuth Reddit API interactions (such as `token`) & corresponding logic
///
final class RedditSession {

	static var shared = RedditSession()
	
	///
	/// If `false`, you need to initialize a session through performing OAuth request.
	///
	var sessionInitialized: Bool { accessCode.value != nil }
	
	///
	/// The token which must be used in requests to Reddit API.
	/// The token is valid for 1 hour; after that it must be refreshed through `performRefreshToken`.
	///
	private(set) var accessToken: String?
	
	///
	/// Use this to perform the refresh token request.
	///
	private(set) var refreshToken: String?
	
	///
	/// The access code needed to request/refresh the `accessToken`.
	///
	private var accessCode = StoredProperty<String>(key: "RedditSession.accessCode")

	///
	/// Call this function after OAuth succeeded
	/// - Parameter accessCodeValue: The access code granted by Reddit
	///
	func accessCodeRecieved(_ accessCodeValue: String) {
		accessCode.value = accessCodeValue
	}
	
	///
	/// Whenever you get a token expired error, call this function and resend the request.
	///
	func performRefreshToken() {
		
	}
	
	private func retrieveToken() {
		
	}
	
}


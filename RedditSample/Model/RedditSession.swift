//
//  RedditSession.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation

///
/// Contains data required for OAuth Reddit API interactions (such as `accessToken`) & corresponding logic.
///
final class RedditSession {

	static var shared = RedditSession()
	
	///
	/// If `false`, you need to initialize a session through performing OAuth request
	/// and calling `accessCodeRecieved` on success.
	///
	var sessionInitialized: Bool { accessCode.value != nil }
	
	///
	/// The token which must be used in requests to Reddit API (along with corresponding data).
	/// The token is valid for 1 hour; after that it must be refreshed through `performRefreshToken`.
	///
	private(set) var accessToken: AccessToken?
	
	///
	/// The access code needed to request/refresh the `accessToken`.
	///
	private var accessCode = StoredProperty<String>(key: "RedditSession.accessCode")

	///
	/// Call this function after OAuth succeeded. It will save the access code and retrieve a token.
	/// - Parameter accessCodeValue: The access code granted by Reddit
	///
	func accessCodeRecieved(_ accessCodeValue: String, callback: @escaping OptionalErrorCallback) {
		print("\(#function)")
		accessCode.value = accessCodeValue
		retrieveToken(callback)
	}
	
	///
	/// Whenever you get a token expired error, call this function.
	/// In most cases you may want to resend the failed request on (successfull) callback.
	///
	func performRefreshToken(_ callback: OptionalErrorCallback) {
		
	}
	
	///
	/// Call this function to get a token after receiving a valid access code
	///
	private func retrieveToken(_ callback: @escaping OptionalErrorCallback) {
		Network.shared.request(.accessToken(code: accessCode.value!)) { [weak self] (data, error) in
			
			self?.accessToken = try! AccessToken(jsonData: data!)			
			callback(error)
		}
	}
	
}


//
//  RedditSession.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation
import UIKit

///
/// Contains data required for OAuth Reddit API interactions (such as `accessToken`) & corresponding logic.
///
final class Session {

	static var shared = Session()
	
	private init() { }
	
	///
	/// If `false`, you need to initialize a session through performing OAuth request
	/// and calling `accessCodeRecieved` on success.
	///
	var sessionInitialized: Bool { accessCode.value != nil && token.value != nil}
	
	///
	/// The token which must be used in requests to Reddit API.
	/// The token is valid for 1 hour; after that it must be refreshed through `performRefreshToken`.
	///
	private(set) var token = StoredProperty<String>(key: "RedditSession.accessToken")
	
	///
	/// Needed to refresh the `accessToken`
	///
	private var refreshToken = StoredProperty<String>(key: "RedditSession.refreshToken")
	
	///
	/// The access code needed to request/refresh the `accessToken`.
	///
	private var accessCode = StoredProperty<String>(key: "RedditSession.accessCode")

	///
	/// Call this method to initialize the Reddit session. It will retrieve the access code and/or token - depending on the current state.
	///
	func enableAccess(_ callback: @escaping OptionalErrorCallback) {
		if refreshToken.value != nil {
			refreshToken(callback)
		}
		else if accessCode.value != nil {
			getToken(callback)
		}
		else {
			authentificate(callback)
		}
	}
	
	///
	/// Whenever you get a token expired error, call this function.
	/// In most cases you may want to resend the failed request on (successfull) callback.
	/// If `refreshToken` is empty, fallback to the `getToken` flow.
	///
	func refreshToken(_ callback: @escaping OptionalErrorCallback) {
		token.value = nil
		guard let refreshTokenValue = refreshToken.value else {
			getToken(callback)
			return
		}
		Network.shared.request(.accessToken(
								grantType:"refresh_token",
								code: nil,
								refreshToken:refreshTokenValue)
		) { [weak self] (json, error) in
			if error == nil {
				self?.tokenResponseReceived(json)
			}
			else {
				ErrorHandler.shared.process(error)
			}
			
			callback(error)
		}
	}
	
}

//MARK:- Private
private extension Session {

	///
	/// Reset to initial state
	///
	func clear() {
		accessCode.value = nil
		token.value = nil
		refreshToken.value = nil
	}
	
	//MARK:- Access code
	///
	/// Perform OAuth authentification with further data load. Clears existed data on call.
	///
	func authentificate(_ callback: @escaping OptionalErrorCallback) {
		clear()
		
		let authVC = OAuthVC.loadFromStoryboard()!
		let navigationWrapper = UINavigationController(rootViewController: authVC)
		
		authVC.authFinishedCallback = { [weak authVC] (code, error) in
			authVC?.presentingViewController?.dismiss(animated: true) {
				if let accessCode = code {
					self.accessCodeRecieved(accessCode, callback: callback)
				}
				else {
					Alert.shared.show(title: "Access denied",
									  message: "Please allow access in order to see the top posts.")
				}
			}
		}
		
		Alert.shared.show(controller: navigationWrapper)
	}
	
	///
	/// Callback for OAuth controller.
	/// - Parameter accessCodeValue: The access code granted by Reddit
	///
	func accessCodeRecieved(_ accessCodeValue: String, callback: @escaping OptionalErrorCallback) {
		accessCode.value = accessCodeValue
		getToken(callback)
	}

	///
	/// Whenever access code expires, it must be retrieved again along with tokens.
	///
	func onAccessCodeExpired(_ callback: @escaping OptionalErrorCallback) {
		authentificate(callback)
	}
		
	//MARK:- Token
	///
	/// Call this function to get a token after receiving a valid access code.
	/// If `accessCode` is empty, falls back
	///
	func getToken(_ callback: @escaping OptionalErrorCallback) {
		guard let accessCodeValue = accessCode.value else {
			authentificate(callback)
			return
		}
		
		Network.shared.request(.accessToken(
								grantType:"authorization_code",
								code: accessCodeValue,
								refreshToken:nil)
		) { [weak self] (json, error) in
			switch error {
			case nil:
				self?.tokenResponseReceived(json)
				callback(nil)
			case .reddit(.invalid_grant):
				self?.onAccessCodeExpired(callback)
			default:
				callback(error)
			}
		}
	}
	
	///
	/// Update stored `token` & `refreshToken`
	///
	func tokenResponseReceived(_ json: JSONDict?) {
		
		guard let tokenData = try? AccessToken(jsonDict: json!) else {
			ErrorHandler.shared.process(descr: "Access token parse failed")
			return
		}
		
		token.value = tokenData.token
		// The refresh token appears to be returned only on the initial request; avoid rewriting it with an empty value.
		if let newRefreshToken = tokenData.refreshToken {
			refreshToken.value = newRefreshToken
		}
	}

}

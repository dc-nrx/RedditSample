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
	/// The token which must be used in requests to Reddit API (along with corresponding data).
	/// The token is valid for 1 hour; after that it must be refreshed through `performRefreshToken`.
	///
	private(set) var token = StoredProperty<String>(key: "RedditSession.accessToken")
	
	///
	/// Needed to refresh the `accessToken`
	///
	private(set) var refreshToken = StoredProperty<String>(key: "RedditSession.refreshToken")
	
	///
	/// The access code needed to request/refresh the `accessToken`.
	///
	private var accessCode = StoredProperty<String>(key: "RedditSession.accessCode")

	///
	/// Call this method to initialize the Reddit session. It will retrieve the access code and/or token - depending on the current state.
	/// - Parameter presentingController: A controller to present a `OAuthVC` with ( if needed)
	///
	func enableAccess(presentingController: UIViewController, _ callback: @escaping OptionalErrorCallback) {
		if accessCode.value != nil {
			getToken(presentingController: presentingController, callback)
		}
		else {
			authentificate(presentingController: presentingController, callback)
		}
	}
	
	///
	/// Whenever you get a token expired error, call this function.
	/// In most cases you may want to resend the failed request on (successfull) callback.
	///
	func refreshToken(_ callback: OptionalErrorCallback) {
		token.value = nil
		guard let refreshTokenValue = refreshToken.value else {
			#warning("call getToken here")
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
				// TODO: process error
			}
		}
	}
	
}

//MARK:- Private
private extension Session {

	///
	/// Reset to the initial state
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
	func authentificate(presentingController: UIViewController, _ callback: @escaping OptionalErrorCallback) {
		
		clear()
		let authVC = UIStoryboard(name: "OAuthVC", bundle: nil).instantiateInitialViewController() as! OAuthVC
		authVC.callback = { (code, error) in
			presentingController.dismiss(animated: true, completion: nil)
			self.accessCodeRecieved(presentingController: presentingController, code!, callback: callback)
		}
		presentingController.present(authVC, animated: true, completion: nil)
	}
	
	///
	/// Callback for OAuth controller.
	/// - Parameter accessCodeValue: The access code granted by Reddit
	///
	func accessCodeRecieved(presentingController: UIViewController, _ accessCodeValue: String, callback: @escaping OptionalErrorCallback) {
		accessCode.value = accessCodeValue
		getToken(presentingController: presentingController, callback)
	}

	///
	/// Whenever access code expires, it must be retrieved again along with tokens.
	///
	func onAccessCodeExpired(presentingController: UIViewController, _ callback: @escaping OptionalErrorCallback) {
		authentificate(presentingController: presentingController, callback)
	}
		
	//MARK:- Token
	///
	/// Call this function to get a token after receiving a valid access code
	///
	func getToken(presentingController: UIViewController, _ callback: @escaping OptionalErrorCallback) {
		Network.shared.request(.accessToken(
								grantType:"authorization_code",
								code: accessCode.value!,
								refreshToken:nil)
		) { [weak self] (json, error) in
			switch error {
			case nil:
				self?.tokenResponseReceived(json)
			case .reddit(.invalid_grant):
				self?.onAccessCodeExpired(presentingController: presentingController, callback)
			default:
				callback(error)
			}
		}
	}
	
	///
	/// Update stored `token` & `refreshToken`
	///
	func tokenResponseReceived(_ json: JSONDict?) {
		#warning("check for nil")
		let tokenData = try? AccessToken(jsonDict: json!)
		token.value = tokenData?.token
		refreshToken.value = tokenData?.refreshToken
	}

}

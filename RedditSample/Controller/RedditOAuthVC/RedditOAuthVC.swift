//
//  RedditOAuthVC.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation
import WebKit
import UIKit

///
/// A controller which provides a convenient OAuth flow to retrieve Reddit request token.
///
class RedditOAuthVC: UIViewController {

	typealias Callback = (_ error: String, _ code: String) -> ()
	
	convenience init(callback: @escaping Callback) {
		self.init(nibName: "RedditOAuthVC", bundle: nil)
		self.callback = callback
	}
	
	//MARK:- Public Members
	
	///
	/// The callback to execute on the OAuth flow finish.
	///
	var callback: Callback!
	
	//MARK:- Outlets
	@IBOutlet private var webView: WKWebView!

	//MARK:- Private Members
//	private let	clientId = Reddit.clientId
//	private let	responseType = "code"
//	private let state = UUID().uuidString
//	private let redirectURIString = Reddit.redirectURIString
//	private let duration = "permanent"
	
	///
	/// The initial OAth request to execute.
	/// Please see https://github.com/reddit-archive/reddit/wiki/OAuth2 for details
	/// (e.g. you might want to extend `scope` with extra API areas to support other requests)
	///
	private let oathRequest: URLRequest = {
		let params = [
			"client_id": Reddit.clientId,
			"response_type": "code",
			"state": UUID().uuidString,
			"redirect_uri": Reddit.redirectURIString,
			"duration": "permanent",
			"scope": "read"
		]
		var components = URLComponents(string: "https://www.reddit.com/api/v1/authorize")!
		components.queryItems = params.map(URLQueryItem.init)
//		{ (key, value) in
//			URLQueryItem(name: key, value: value)
//		}
		
		return URLRequest(url: components.url!)
	}()
	
}

//MARK:- Public
extension RedditOAuthVC {
	
}

//MARK:- Life Cycle
extension RedditOAuthVC {
	
	override func viewDidLoad() {
		super.viewDidLoad()

		webView.load(oathRequest)
	}
	
}

//MARK:- Private
private extension RedditOAuthVC {
	
}

////MARK:- Protocols
////MARK:-
//extension RedditOAuthVC:  {
//
//}

//
//  RedditOAuthVC.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation
import WebKit
import UIKit

enum OAuthVCError: Error {
	case noCode
}

///
/// A controller which provides a convenient OAuth flow to retrieve Reddit request token.
///
class OAuthVC: UIViewController {

	typealias Callback = (_ code: String?, Error?) -> ()
	
	//MARK:- Public Members
	
	///
	/// The query param key for the Reddit access code (which is the result we expect after OAuth succeeds)
	///
	let codeKey = "code"
	
	///
	/// The callback to execute on the OAuth flow finish.
	///
	var authFinishedCallback: Callback?
	
	//MARK:- Outlets
	
	///
	/// The main web view for oauth user interactions
	///
	@IBOutlet private var webView: WKWebView!

	//MARK:- Private Members
	
	///
	/// The initial OAth request to execute.
	/// Please see https://github.com/reddit-archive/reddit/wiki/OAuth2 for details
	/// (e.g. you might need to extend the `scope` param with extra API areas to add new requests)
	///
	private let oathRequest: URLRequest = {
		let params = [
			"client_id": API.clientId,
			"response_type": "code",
			"state": UUID().uuidString,
			"redirect_uri": API.redirectURIString,
			"duration": "permanent",
			"scope": "read"
		]
		var components = URLComponents(string: "https://www.reddit.com/api/v1/authorize.compact")!
		components.queryItems = params.map(URLQueryItem.init)
		
		return URLRequest(url: components.url!)
	}()
	
}

//MARK:- Public
extension OAuthVC {
	
}

//MARK:- Life Cycle
extension OAuthVC {
	
	override func viewDidLoad() {
		super.viewDidLoad()

		webView.navigationDelegate = self
		webView.load(oathRequest)
	}
	
}

//MARK:- Private
private extension OAuthVC {
	
}

//MARK:- Protocols
//MARK:- WKNavigationDelegate
extension OAuthVC: WKNavigationDelegate {

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		
		print("####### \(navigationAction.request)")
		
		if let absoluteURLString = navigationAction.request.url?.absoluteString,
		   absoluteURLString.hasPrefix(API.redirectURIString) {
			// Auth succeeded case
			if let code = getQueryStringParameter(url: absoluteURLString, param: codeKey) {
				self.authFinishedCallback?(code, nil)
			}
			else {
				self.authFinishedCallback?(nil, OAuthVCError.noCode)
			}
				
			decisionHandler(.cancel)
		}
		else {
			// Regular case
			decisionHandler(.allow)
		}
	}
	
}

//MARK:- Tools
private extension OAuthVC {
	
	func getQueryStringParameter(url: String?, param: String) -> String? {
		if let url = url,
		   let urlComponents = NSURLComponents(string: url),
		   let queryItems = (urlComponents.queryItems as [NSURLQueryItem]?) {
			return queryItems.filter({ (item) in item.name == param }).first?.value!
		}
		return nil
	}
	
}

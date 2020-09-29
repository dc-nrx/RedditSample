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
	private let	clientId = Reddit.clientId
	private let	responseType = "code"
	private let state = UUID().uuidString
	private let redirectURIString = Reddit.redirectURIString
	private let duration = "permanent"
	
}

//MARK:- Public
extension RedditOAuthVC {
	
}

//MARK:- Life Cycle
extension RedditOAuthVC {
	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		//...
//	}
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		//...
//	}
	
}

//MARK:- Private
private extension RedditOAuthVC {
	
}

////MARK:- Protocols
////MARK:-
//extension RedditOAuthVC:  {
//
//}

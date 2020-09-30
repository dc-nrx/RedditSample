//
//  ViewController.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import UIKit

class RedditMainVC: UITableViewController {

	///
	/// Shown items
	///
	var items = [Any]()
	
	///
	/// Number of items to request per 1 page
	///
	let limit = 25
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if RedditSession.shared.sessionInitialized {
			loadData()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if !RedditSession.shared.sessionInitialized {
			authentificate()
		}
	}

}

//MARK:- Private
private extension RedditMainVC {
		
	///
	/// Perform OAuth authentification with further data load
	///
	func authentificate() {
		
		let authVC = UIStoryboard(name: "RedditMainVC", bundle: nil).instantiateInitialViewController() as! RedditOAuthVC
		authVC.callback = { [weak self] error in
			self?.dismiss(animated: true, completion: nil)
			self?.refresh()
		}
		present(authVC, animated: true, completion: nil)
	}
	
	///
	/// Reload data
	///
	func refresh() {
		items.removeAll()
		loadData()
	}
	
	///
	/// Load the next / initial page
	///
	func loadData() {
		//...
	}
}

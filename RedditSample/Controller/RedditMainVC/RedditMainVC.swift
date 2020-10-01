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
		
		if RedditSession.shared.sessionInitialized,
		   items.count == 0 {
			// Refresh only if there's no data to support state restoration
			//TODO: use nsuseractivity instead
			refresh()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if !RedditSession.shared.sessionInitialized {
			RedditSession.shared.enableAccess(presentingController: self) { [weak self] (error) in
				self?.refresh()
			}
		}
	}

}

//MARK:- Private
private extension RedditMainVC {
		
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

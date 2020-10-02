//
//  ViewController.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import UIKit

class TopLinksVC: UITableViewController {

	///
	/// Shown items
	///
	var listing = Listing<Link>()
	
	///
	/// Number of items to request per 1 page
	///
	let limit = 25
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if Session.shared.sessionInitialized,
		   listing.count == 0 {
			// Refresh only if there's no data to support state restoration
			//TODO: use nsuseractivity instead
			refresh()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Initialize the reddit session if needed with further content refresh
		if !Session.shared.sessionInitialized {
			Session.shared.enableAccess(presentingController: self) { [weak self] (error) in
				self?.refresh()
			}
		}
	}

}

//MARK:- Private
private extension TopLinksVC {
		
	///
	/// Reload data
	///
	func refresh() {
		listing.removeAll()
		loadData()
	}
	
	///
	/// Load the next / initial page
	///
	func loadData() {
		
//		Network.shared.request(.topFeed) { (json, error) in
////			print("\(json), \(error)")
//		}
	}
}

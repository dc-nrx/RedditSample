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
	let defaultLimit: UInt = 25
	
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
			Session.shared.enableAccess { [weak self] (error) in
				self?.refresh()
			}
		}
	}
	
}

//MARK:- Private
private extension TopLinksVC {
		
	func updateUI() {
		tableView.reloadData()
	}
	
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
		
		let request = API.topFeed(afterFullname: listing.last?.fullname, limit: defaultLimit)
		Network.shared.request(request) { [weak self] (json, error) in
			print("### \(#function) error\(String(describing: error))")
			if let json = json,
			   let listing = try? Listing<Link>(jsonDict: json) {
				print("\(listing)")
				self?.listing.merge(with: listing)
				self?.updateUI()
			}
		}
	}
}

//MARK:- Table View Delegate
extension TopLinksVC {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		listing.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell") as! LinkCell
		cell.link = listing[indexPath.row]
		
		return cell
	}
	
}

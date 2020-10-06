//
//  ViewController.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import UIKit


class TopLinksVC: UITableViewController {

	private enum CoderKey: String {
		case listing
		case firstShownIndexPath
	}
	
	///
	/// Shown items
	///
	var listing = Listing<Link>()
	
	///
	/// Number of items to request per 1 page
	///
	let defaultLimit: UInt = 25
	
	private var updateInProgress = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if Session.shared.sessionInitialized,
		   listing.count == 0 {
			// Refresh only if there's no data to support state restoration
			//TODO: use nsuseractivity instead
			loadData(refresh: true)
		}
		
		addTopRefreshControl()
		
//		restorationIdentifier = "TopLinksVC"
		restorationClass = TopLinksVC.self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Initialize the reddit session if needed with further content refresh
		if !Session.shared.sessionInitialized {
			Session.shared.enableAccess { [weak self] (error) in
				self?.loadData(refresh: true)
			}
		}
	}
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		
		coder.encode(listing, forKey: CoderKey.listing.rawValue)
		if let firstShownIndexPath = tableView.indexPathsForVisibleRows?.first {
			coder.encode(firstShownIndexPath, forKey: CoderKey.firstShownIndexPath.rawValue)
		}
		
		print("\(#function)")
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		
		listing = coder.decodeObject(forKey: CoderKey.listing.rawValue) as! Listing<Link>
		if let firstShownIndexPath = coder.decodeObject(forKey: CoderKey.listing.rawValue) as? IndexPath {
			tableView.scrollToRow(at: firstShownIndexPath, at: .top, animated: false)
		}
		print("\(#function)")
	}
}

//MARK:- Actions
extension TopLinksVC {
	
	@objc func onRefresh(_ sender: UIRefreshControl) {
		loadData(refresh: true)
	}
	
}

//MARK:- Private
//MARK:- UI Components
private extension TopLinksVC {

	func updateUI() {
		tableView.reloadData()
	}

	func addTopRefreshControl() {
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
	}
	
	func addBottomRefreshControlIfNeeded() {
		if tableView.tableFooterView == nil {
			let spinner = UIActivityIndicatorView(style: .medium)
			spinner.startAnimating()
			spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

			tableView.tableFooterView = spinner
		}
	}
	
	func showBottomRefreshControl(_ show: Bool) {
		addBottomRefreshControlIfNeeded()
		tableView.tableFooterView?.isHidden = !show
	}
	
	func endRefreshigUI() {
		self.tableView.refreshControl?.endRefreshing()
		showBottomRefreshControl(false)
	}
}

//MARK:- Data Retrieve
private extension TopLinksVC {
			
	///
	/// Load the next / initial page
	/// - Parameter refresh: If `true`, rewrite existed data newly loaded first page;
	/// 	append newly loaded next page to existed data otherwise.
	///
	func loadData(refresh: Bool = false) {
		guard !updateInProgress else { return }
		updateInProgress = true
		
		// Decide whether to load the first or the next page.
		let afterFullname = refresh ? nil : listing.after
		
		let request = API.topFeed(afterFullname: afterFullname, limit: defaultLimit, count: UInt(listing.count))
		Network.shared.request(request) { [weak self] (json, error) in
			// Clear existed data in case of refresh
			if refresh {
				self?.listing.removeAll()
			}
			if let json = json,
			   let listing = try? Listing<Link>(jsonDict: json) {
				self?.listing.append(listing)
			}
			else {
				ErrorHandler.shared.process(error: error ?? NetworkError.unexpectedResponseObject)
			}
			
			self?.updateUI()
			self?.endRefreshigUI()
			self?.updateInProgress = false
			
//			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//				exit(0)
//			}
		}
	}
}

//MARK:- Table View Data Source
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

//MARK:- Table View Delegate
extension TopLinksVC {
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let lastSectionIndex = tableView.numberOfSections - 1
		let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
		if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
			showBottomRefreshControl(true)
			loadData()
		}
	}
	
}

extension TopLinksVC: UIViewControllerRestoration {
	
	static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
		let vc = TopLinksVC()
		return vc
	}

}

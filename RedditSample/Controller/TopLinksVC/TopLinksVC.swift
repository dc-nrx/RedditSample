//
//  ViewController.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import UIKit


class TopLinksVC: UITableViewController {

	///
	/// Keys for persistant data storage (both in persistant store & via NSCoder)
	///
	private enum DataKey: String {
		case listing = "TopLinksVC_listing_cache.json"
		case firstShownRow = "TopLinksVC.firstShownIndexPath"
		case openedLink = "TopLinksVC.openedLinkFullname"
	}
		
	///
	/// Shown items
	///
	var listing = Listing<Link>()
	
	///
	/// Number of items to request per 1 page
	///
	let defaultLimit: UInt = 25
	
	///
	/// Needed to avoid redundant requests & conflicts between updates from persistant store / backend
	///
	private var modelUpdateInProgress = false
	
	///
	/// Needed to void redundant table view updated on cells height change
	///
	private var uiUpdateInProgress = false
	
	//MARK:- Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		addTopRefreshControl()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("\(#function)")
		
		// Initialize the reddit session if needed with further content refresh
		let optionallyRefreshData: OptionalErrorCallback = { [weak self] _ in
			if self?.listing.count == 0 {
				self?.loadData(refresh: true)
			}
		}
		
		if !Session.shared.sessionInitialized {
			Session.shared.enableAccess(optionallyRefreshData)
		}
		else {
			optionallyRefreshData(nil)
		}
	}
	
	//MARK:- State restoration
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		print("\(#function)")

		PersistentStore.write(listing, filename: DataKey.listing.rawValue)
		if let firstShownRow = tableView.indexPathsForVisibleRows?.first?.row {
			coder.encode(firstShownRow, forKey: DataKey.firstShownRow.rawValue)
			print("\(firstShownRow)")
		}
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		modelUpdateInProgress = true

		let firstShownRow = coder.decodeInteger(forKey: DataKey.firstShownRow.rawValue)
		print("\(#function), \(String(describing: firstShownRow))")
		PersistentStore.read(filename: DataKey.listing.rawValue) { [weak self] (storedListing: Listing<Link>?) in
			// Update data
			if let storedListing = storedListing {
				self?.listing = storedListing
				self?.tableView.reloadData()
				// Update scroll position
				self?.tableView.scrollToRow(at: IndexPath(row: firstShownRow, section: 0), at: .top, animated: false)
			}
			
			self?.modelUpdateInProgress = false
			print("\(#function) \(self!.listing.count)")
		}
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
	/// - Parameter refresh: If `true`, rewrite existed data with a newly loaded first page;
	/// 	otherwise append a newly loaded next page to the existed data.
	///
	func loadData(refresh: Bool = false) {
		guard !modelUpdateInProgress else { return }
		modelUpdateInProgress = true
		// Show progress only for initial load & without manual refresh
		let showProgress = listing.count == 0 && !tableView.refreshControl!.isRefreshing
		if showProgress {
			Alert.shared.showProgress(true)
		}
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
				ErrorHandler.shared.process(error ?? NetworkError.unexpectedResponseObject)
			}
			
			self?.updateUI()
			self?.endRefreshigUI()
			self?.modelUpdateInProgress = false
			
			if showProgress {
				Alert.shared.showProgress(false)
			}
		}
	}
	
}

//MARK:- Table View Data Source
extension TopLinksVC {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		listing.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell") as! LinkCell
		cell.link = listing[indexPath.row]
		cell.delegate = self
		
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let detailsVC = LinkDetailsVC.loadFromStoryboard()! 
		detailsVC.link = listing[indexPath.row]
		navigationController?.pushViewController(detailsVC, animated: true)
	}
}

//MARK:- Link Cell Delegate
extension TopLinksVC: LinkCellDelegate {
	
	func linkCellImageChanged(_ cell: LinkCell) {
		guard !uiUpdateInProgress else { return }
		uiUpdateInProgress = true
		// Update cell heights
		tableView.performBatchUpdates(nil, completion: nil)
		uiUpdateInProgress = false
	}
	
}

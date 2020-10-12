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
		case openedRow = "TopLinksVC.openedRow"
	}
	
	///
	/// Shown items
	///
	private var links = Listing<Link>()
	
	///
	/// Number of items to request per 1 page
	///
	private let kDefaultLimit: UInt = 25
	
	///
	/// Needed to avoid redundant requests & conflicts between updates from persistant store / backend
	///
	private var modelUpdateInProgress = false
	
	///
	/// A sentinel value for "no open row" case to store in coder under `DataKey.openedRow` key.
	///
	private let kNoOpenRowSentinelValue: Int = -1
	
	//MARK:- Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		addTopRefreshControl()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Initialize the reddit session if needed with further content refresh
		let optionallyRefreshData: OptionalErrorCallback = { [weak self] _ in
			if self?.links.count == 0 {
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

		PersistentStore.write(links, filename: DataKey.listing.rawValue)
		
		let firstShownRow = tableView.indexPathsForVisibleRows?.first?.row ?? 0
		coder.encode(firstShownRow, forKey: DataKey.firstShownRow.rawValue)
		
		coder.encode(openedRowIndex, forKey: DataKey.openedRow.rawValue)
		
	}
	
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		modelUpdateInProgress = true

		let firstShownRow = coder.decodeInteger(forKey: DataKey.firstShownRow.rawValue)
		let openedRow = coder.decodeInteger(forKey: DataKey.openedRow.rawValue)
		PersistentStore.read(filename: DataKey.listing.rawValue) { [weak self] (storedListing: Listing<Link>?) in
			// Update data
			guard let `self` = self else { return }
			if let storedListing = storedListing {
				self.links = storedListing
				self.tableView.reloadData()
				// Update scroll position
				self.tableView.scrollToRow(at: IndexPath(row: firstShownRow, section: 0), at: .top, animated: false)
				// Open link details if needed
				if openedRow < self.links.count,
				   openedRow != self.kNoOpenRowSentinelValue {
					self.openLinkDetails(link: self.links[openedRow])
				}
			}
			
			self.modelUpdateInProgress = false
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
	
	func openLinkDetails(link: Link) {
		let detailsVC = LinkDetailsVC.loadFromStoryboard()!
		detailsVC.link = link
		navigationController?.pushViewController(detailsVC, animated: true)
	}
	
	///
	/// A helper var to get the currently presented LinkVC
	///
	var openedRowIndex: Int {
		if let presentedLinkVC = (navigationController?.viewControllers.first { $0 is LinkDetailsVC }) as? LinkDetailsVC,
		   let index = (links.firstIndex {$0.fullname == presentedLinkVC.link.fullname}) {
			return index
		}
		else {
			return kNoOpenRowSentinelValue
		}
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
		let showProgress = links.count == 0 && !tableView.refreshControl!.isRefreshing
		if showProgress {
			Alert.shared.showProgress(true)
		}
		// Decide whether to load the first or the next page.
		let afterFullname = refresh ? nil : links.after
		
		let request = API.topFeed(afterFullname: afterFullname, limit: kDefaultLimit, count: UInt(links.count))
		Network.shared.request(request) { [weak self] (json, error) in
			// Clear existed data in case of refresh
			if refresh {
				self?.links.removeAll()
			}
			if let json = json,
			   let listing = try? Listing<Link>(jsonDict: json) {
				self?.links.append(listing)
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
		links.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell") as! LinkCell
		cell.link = links[indexPath.row]
		
		return cell
	}
	
}

//MARK:- Table View Delegate
extension TopLinksVC {
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let lastSectionIndex = tableView.numberOfSections - 1
		let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
		if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex,
		   !Network.shared.connectionLost {	// avoid 1oo5oo requests per second
			showBottomRefreshControl(true)
			loadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		openLinkDetails(link: links[indexPath.row])
	}
}

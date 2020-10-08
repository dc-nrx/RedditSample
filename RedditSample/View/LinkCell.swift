//
//  RedditPostCell.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation
import UIKit

protocol LinkCellDelegate: AnyObject {
	func linkCellImageChanged(_ cell: LinkCell)
}

class LinkCell: UITableViewCell {
	
	weak var delegate: LinkCellDelegate?
	
	//MARK:- Public Members
	var link: Link! {
		didSet {
			updateUI()
		}
	}
	
	//MARK:- Outlets
	@IBOutlet private var subredditNameLabel: UILabel!
	@IBOutlet private var userDateLabel: UILabel!
	@IBOutlet private var titleLabel: UILabel!
	/// Link image
	@IBOutlet private var linkImageView: UIImageView!
	@IBOutlet private var imageHeightConstraint: NSLayoutConstraint!
	@IBOutlet private var commentsLabel: UILabel!
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	
}

//MARK:- Public
extension LinkCell {
	
	func updateUI() {
		subredditNameLabel.text = link.subredditNamePrefixed
		
		titleLabel.text = link.title
		userDateLabel.text = "\(link.author) - \(link.createdUtc.agoString)"
		commentsLabel.text = "Comments: \(link.commentsCount)"
		
		handleImage()
	}
	
}

//MARK:- Private
private extension LinkCell {
	
	func handleImage() {
		guard let url = link.thumbLink else {
			self.updateImage(nil)
			return
		}
		
		if let cachedImage = ImagesManager.sharedInstance().getCachedImage(for: url) {
			self.updateImage(cachedImage)
		}
		else {
			self.updateImage(nil)
			activityIndicator.startAnimating()
			ImagesManager.sharedInstance().loadImage(for: url) { [weak self] (image) in
				// link could've changed at this point
				guard let `self` = self,
					  self.link.thumbLink == url else { return }
				self.updateImage(image)
				self.activityIndicator.stopAnimating()
				
				self.delegate?.linkCellImageChanged(self)
			}
		}
	}
	
	func updateImage(_ image: UIImage?) {
		self.linkImageView?.image = image
		self.linkImageView.isHidden = (image == nil)
	}
	
}

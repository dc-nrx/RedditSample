//
//  RedditPostCell.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 29.09.2020.
//

import Foundation
import UIKit

class LinkCell: UITableViewCell {
		
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
	@IBOutlet private var thumbView: UIImageView!
	@IBOutlet private var imageHeightConstraints: [NSLayoutConstraint]!
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
		imageHeightConstraints.forEach { $0.constant = CGFloat(link.thumbHeight ?? 0) }
		if let cachedImage = ImagesManager.sharedInstance().getCachedImage(for: url) {
			self.updateImage(cachedImage)
		}
		else {
			self.updateImage(nil, loadingInProgress: true)
			ImagesManager.sharedInstance().loadImage(for: url) { [weak self] (image) in
				// link could've changed at this point
				guard let `self` = self,
					  self.link.thumbLink == url else { return }
				self.updateImage(image)
				self.activityIndicator.stopAnimating()
			}
		}
	}
	
	func updateImage(_ image: UIImage?, loadingInProgress: Bool = false) {
		self.thumbView?.image = image
		self.thumbView.isHidden = (image == nil)
		
		if loadingInProgress {
			activityIndicator.startAnimating()
		}
		else {
			activityIndicator.stopAnimating()
		}
		
	}
	
}

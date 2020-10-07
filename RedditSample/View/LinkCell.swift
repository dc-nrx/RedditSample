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
		didSet { updateUI() }
	}
	
	//MARK:- Outlets
	@IBOutlet private var subredditNameLabel: UILabel!
	@IBOutlet private var userLabel: UILabel!
	@IBOutlet private var timeLabel: UILabel!
	@IBOutlet private var titleLabel: UILabel!
	/// Link image
	@IBOutlet private var linkImageView: UIImageView!
	/// `ups` - `downs`
	@IBOutlet private var ratingLabel: UILabel!
	
	//MARK:- Private Members
	
}

//MARK:- Public
extension LinkCell {
	
	func updateUI() {
		subredditNameLabel.text = link.subredditNamePrefixed
		
		titleLabel.text = link.title
		timeLabel.text = link.createdUtc.format("d MMM yyyy HH:mm:ss")
		if let url = link.thumbLink {
			ImagesManager.sharedInstance().loadImage(for: url) { [weak self] (image) in
				// link could've changed at this point
				guard let `self` = self,
					  self.link.thumbLink == url else { return }
				self.linkImageView?.image = image
			}
		}
	}
	
}

//MARK:- Private
private extension LinkCell {
	
}

//
//  LinkDetailsVC.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 08.10.2020.
//

import Foundation

class LinkDetailsVC: UIViewController {

	//MARK:- Public Members
	var link: Link! {
		didSet {
			if isViewLoaded {
				updateUI()
			}
		}
	}
	//MARK:- Private Members
	
	//MARK:- Outlets
	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
}

//MARK:- Public
extension LinkDetailsVC {
	
}

//MARK:- Life Cycle
extension LinkDetailsVC {
	
	override func viewDidLoad() {
		super.viewDidLoad()

		updateUI()
	}
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		//...
//	}
	
}

//MARK:- Private
private extension LinkDetailsVC {
	
	func updateUI() {
		if let url = link.mainImageURL {
			ImagesManager.sharedInstance().loadImage(for: url) { (image) in
				self.imageView.image = image
			}
		}
		titleLabel.text = link.title
	}
}

////MARK:- Protocols
////MARK:-
//extension LinkDetailsVC:  {
//
//}

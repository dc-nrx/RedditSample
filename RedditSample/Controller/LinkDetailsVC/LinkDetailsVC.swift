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
	@IBOutlet private var saveImageButton: UIButton!
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
	
}

//MARK:- Actions
extension LinkDetailsVC {
	
	@IBAction func onSaveImage(_ sender: UIButton) {
		
	}
	
}

//MARK:- Private
private extension LinkDetailsVC {
	
	func updateUI() {
		titleLabel.text = link.title
		updateSaveImageButton()
		if let url = link.mainImageURL {
			Alert.shared.showProgress(true)
			ImagesManager.sharedInstance().loadImage(for: url) { [weak self] (image) in
				Alert.shared.showProgress(false)
				self?.imageView.image = image
				self?.updateSaveImageButton()
				if image == nil {
					ErrorHandler.shared.process(descr: "Sorry, no regular image here\n\(url)")
				}
			}
		}
	}
	
	func updateSaveImageButton() {
		saveImageButton.isEnabled = (imageView.image != nil)
	}
}

////MARK:- Protocols
////MARK:-
//extension LinkDetailsVC:  {
//
//}

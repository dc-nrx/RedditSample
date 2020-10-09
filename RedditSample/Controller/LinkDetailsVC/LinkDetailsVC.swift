//
//  LinkDetailsVC.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 08.10.2020.
//

import Foundation
import Photos

///
/// Link details; current implemetation contains only title, image & ability to save the image into the photos library.
///
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
		guard let image = imageView.image else { return }
		if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .denied {
			Alert.shared.show(title: "Access denied", message: "Please enable access in system preferences")
		}
		else {
			UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		}
	}

	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// we got back an error!
			let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		} else {
			let ac = UIAlertController(title: "Saved!", message: "Please open \"Photos\" app to ensure that everything's fine.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			present(ac, animated: true)
		}
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

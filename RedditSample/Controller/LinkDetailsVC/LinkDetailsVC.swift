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
	
	//MARK:- Outlets
	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var saveImageButton: UIButton!
	@IBOutlet private var imageActivityIndicator: UIActivityIndicatorView!

	//MARK:- Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		updateUI()
	}
}

//MARK:- Actions
extension LinkDetailsVC {
	
	@IBAction func onSaveImage(_ sender: UIButton) {
		guard let image = imageView.image else { return }
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
	}

	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let isPhotosAccessDenied = PHPhotoLibrary.authorizationStatus(for: .addOnly) == .denied
			let message: String = isPhotosAccessDenied ? "Please enable access in system preferences" : error.localizedDescription
			Alert.shared.show(title: "Save error", message: message)
		} else {
			Alert.shared.show(title: "Saved!", message: "Please open \"Photos\" app to ensure that everything's fine.")
		}
	}
	
}

//MARK:- Private
private extension LinkDetailsVC {
	
	func updateUI() {
		titleLabel.text = link.title
		updateSaveImageButton()
		if let url = link.mainImageURL {
			imageActivityIndicator.startAnimating()
			ImagesManager.sharedInstance().loadImage(for: url) { [weak self] (image) in
				self?.imageActivityIndicator.stopAnimating()
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

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
		
	}
}

////MARK:- Protocols
////MARK:-
//extension LinkDetailsVC:  {
//
//}

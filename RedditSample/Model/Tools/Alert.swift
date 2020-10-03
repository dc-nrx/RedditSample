//
//  Alert.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 03.10.2020.
//

import Foundation
import UIKit

class Alert {
	
	enum Actions {
		case none
	}

	static let shared = Alert()
	
	private init() { }
		
	//MARK:- Public
	func show(title: String?, message: String?, actions: Actions = .none) {
		let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		switch actions {
		case .none:
			alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		}
		
		show(controller: alertVC)
	}
	
	func show(controller: UIViewController) {
		self.currentRootVC?.present(controller, animated: true, completion: nil)
	}
	
	//MARK:- Private
	private var currentRootVC: UIViewController? { UIApplication.shared.keyWindow?.rootViewController }
	
}

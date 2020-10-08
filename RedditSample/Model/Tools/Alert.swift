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
	
	private let progressView: UIView = {
		let result = UIView()
		result.backgroundColor = UIColor(white: 0, alpha: 0.2)
		result.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.center = result.center
		activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
		activityIndicator.startAnimating()
		result.addSubview(activityIndicator)
		
		return result
	}()
	
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
	
	func showProgress(_ show: Bool) {
		if show,
		   let currentRootVC = currentRootVC {
			progressView.frame = currentRootVC.view.bounds
			currentRootVC.view.addSubview(progressView)
		}
		else {
			progressView.removeFromSuperview()
		}
		
		currentRootVC?.view.isUserInteractionEnabled = !show
	}
	
	//MARK:- Private
	private var currentRootVC: UIViewController? { AppDelegate.shared.window?.rootViewController }
	
}

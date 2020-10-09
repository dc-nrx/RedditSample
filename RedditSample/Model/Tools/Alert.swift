//
//  Alert.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 03.10.2020.
//

import Foundation
import UIKit

///
/// A helper class to show alerts & loaders.
/// All the things are shown over the current root vc (see `currentRootVC`).
///
final class Alert {
	
	///
	/// Extend it to support alerts with action(s)
	///
	enum Actions {
		case none
	}

	static let shared = Alert()
	
	///
	/// An overlay progress view
	///
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
	
	///
	/// Show an alert
	///
	func show(title: String?, message: String?, actions: Actions = .none) {
		let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		switch actions {
		case .none:
			alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		}
		
		show(controller: alertVC)
	}
	
	///
	/// Show a custom controller in a popover
	///
	func show(controller: UIViewController) {
		self.currentRootVC?.present(controller, animated: true, completion: nil)
	}
	
	///
	/// Show / hide a progress view (completelly blocks user interations)
	///
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

//
//  ErrorHandler.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 03.10.2020.
//

import Foundation

final class ErrorHandler {
	
	static let shared = ErrorHandler()
	
	private init() { }

	//MARK:- Public
	
	func process(error: Error?) {
		var message: String
		if let localizedError = error as? LocalizedError {
			message = localizedError.localizedDescription
		}
		else if error != nil {
			message = String(describing: error)
		}
		else {
			message = "Something went wrong"
		}
		
		DispatchQueue.main.async {
			Alert.shared.show(title: "Error", message: message)
		}
	}
	
	func process(descr: String) {
		DispatchQueue.main.async {
			Alert.shared.show(title: "Error", message: descr)
		}
	}
}

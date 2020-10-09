//
//  StoryboardLoading.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 09.10.2020.
//

import Foundation

//MARK:- Load from storyboard
protocol StoryboardLoading {
	
	/**
	* Load an insctance from a storyboard
	* - parameter storyboardName: Storyboard name. By default == self class name.
	* - parameter identifier: Controller storyboard id. If nil, try to instantiate the initial VC;
	* if storyboard has no initial VC or instantiated controller has a different class,
	* try to instantiate a controller with storyboard id == self class name.
	*/
	static func loadFromStoryboard(storyboardName: String?, identifier: String?) -> Self?
	
}

//MARK:- Conform to StoryboardLoading
extension StoryboardLoading where Self: UIViewController {
	
	/**
	* - parameter storyboardName: default value is String(describing: self)
	* - parameter identifier: default value is nil; if the initial VC of the storyboard has a wrong class or not exist, try to use String(describing: self) as an identifier.
	*/
	static func loadFromStoryboard(storyboardName: String? = nil, identifier: String? = nil) -> Self? {
		let controllerName = String(describing: self)
		let storyboardName = storyboardName ?? controllerName // ?? nameByRemovingGenericSuffix(controllerName)
		let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
		
		if let identifier = identifier,
			let result = storyboard.instantiateViewController(withIdentifier: identifier) as? Self {
			return result
		}
		else if let result = storyboard.instantiateInitialViewController() as? Self {
			return result
		}
		
		return nil
	}
	
	//	private func nameByRemovingGenericSuffix(_ name: String) -> String {
	//		var result = name
	//
	//		if let genericPartStart = result.range(of: "<") {
	//			result.removeSubrange(genericPartStart.lowerBound..<result.endIndex)
	//		}
	//		return result
	//	}
}

extension UIViewController: StoryboardLoading {}


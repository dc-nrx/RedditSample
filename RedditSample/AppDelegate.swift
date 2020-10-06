//
//  AppDelegate.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	static let shared: AppDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

}


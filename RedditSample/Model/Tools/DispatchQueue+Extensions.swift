//
//  DispatchQueue+Extensions.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 09.10.2020.
//

import Foundation

extension DispatchQueue {
	
	static func asyncOnMainIfNeeded(_ block: @escaping ()->()) {
		if Thread.isMainThread {
			block()
		}
		else {
			DispatchQueue.main.async {
				block()
			}
		}
	}
	
}

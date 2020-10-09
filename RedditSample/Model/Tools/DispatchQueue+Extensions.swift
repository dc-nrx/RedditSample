//
//  DispatchQueue+Extensions.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 09.10.2020.
//

import Foundation

extension DispatchQueue {
	
	///
	/// Execute `block` on the main thread (either sync if already on the main, or async if not)
	///
	static func onMain(_ block: @escaping ()->()) {
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

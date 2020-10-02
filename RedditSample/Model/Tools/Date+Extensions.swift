//
//  Date+Extensions.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 02.10.2020.
//

import Foundation

extension Date {

	func format(_ dateFormat: String) -> String {
		
		let formatter = DateFormatter()
		formatter.dateFormat = dateFormat
		return formatter.string(from: self)
	}
	
}

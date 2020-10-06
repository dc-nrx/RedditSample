//
//  TopPage.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

///
/// Corresponds to a "Link"(t3_) listing type.
///
struct Link: ListingItem {
	
	let fullname: String
	let createdUtc: Date
	let subredditNamePrefixed: String?
	let title: String?
	let author: String?
	
	init?(jsonDict: JSONDict) throws {
		fullname = jsonDict["name"] as! String
		subredditNamePrefixed = jsonDict["subreddit_name_prefixed"] as? String
		title = jsonDict["title"] as? String
		author = jsonDict["author"] as? String
		
		let createdTstamp = jsonDict["created_utc"] as! TimeInterval
		createdUtc = Date(timeIntervalSince1970: createdTstamp)
	}
}

//MARK:- Comparable, Hashable
extension Link {
	
	static func < (lhs: Link, rhs: Link) -> Bool {
		lhs.createdUtc < rhs.createdUtc
	}
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.fullname == rhs.fullname
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(fullname.data(using:.utf8)!)
	}
}

//MARK:- Custom String Convertible
extension Link: CustomStringConvertible {

	var description: String {
		return String("\(createdUtc) \(fullname) `\(String(describing: title).dropFirst(10).prefix(20))`\n")
	}
	
}


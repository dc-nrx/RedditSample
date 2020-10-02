//
//  TopPage.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

struct RedditLink: ListingItem {
	
	let fullname: String
	let createdUtc: Date
	let subredditNamePrefixed: String?
	let title: String?
	let ups: Int?
	let downs: Int?
	let author: String?
	let numComments: Int?
	
	init?(jsonDict: JSONDict) throws {
		fullname = jsonDict["name"] as! String
		subredditNamePrefixed = jsonDict["subreddit_name_prefixed"] as? String
		title = jsonDict["title"] as? String
		ups = jsonDict["ups"] as? Int
		downs = jsonDict["downs"] as? Int
		author = jsonDict["author"] as? String
		numComments = jsonDict["num_comments"] as? Int
		
		let createdTstamp = jsonDict["created_utc"] as! TimeInterval
		createdUtc = Date(timeIntervalSince1970: createdTstamp)
	}
}

//MARK:- Comparable, Hashable
extension RedditLink {
	
	static func < (lhs: RedditLink, rhs: RedditLink) -> Bool {
		lhs.createdUtc < rhs.createdUtc
	}
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.fullname == rhs.fullname
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(fullname.data(using:.utf8)!)
	}
}

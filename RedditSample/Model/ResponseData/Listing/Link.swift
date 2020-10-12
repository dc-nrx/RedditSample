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
struct Link: Mappable {
	
	let fullname: String
	let createdUtc: Date
	let author: String
	let title: String
	let commentsCount: UInt
	let subredditNamePrefixed: String?
	let thumbLink: URL?
	let thumbHeight: Float?
	let mainImageURL: URL?
	
	init?(jsonDict: JSONDict) throws {
		fullname = jsonDict["name"] as! String
		subredditNamePrefixed = jsonDict["subreddit_name_prefixed"] as? String
		author = jsonDict["author"] as! String
		commentsCount = jsonDict["num_comments"] as? UInt ?? 0
		title = jsonDict["title"] as! String
		
		let createdTstamp = jsonDict["created_utc"] as! TimeInterval
		createdUtc = Date(timeIntervalSince1970: createdTstamp)
		
		if let urlString = jsonDict["thumbnail"] as? String,
			urlString.hasPrefix("http") {	// Could be a dummy value "self" (at least)
			thumbLink = URL(string: urlString)
		}
		else {
			thumbLink = nil
		}
		
		thumbHeight = jsonDict["thumbnail_height"] as? Float
		if let url = jsonDict["url_overridden_by_dest"] as? String {
			mainImageURL = URL(string: url)
		}
		else {
			mainImageURL = nil
		}
	}
}

//MARK:- Serializable
extension Link {
	
	var json: JSONDict {
		[
			"name": fullname,
			"subreddit_name_prefixed": subredditNamePrefixed,
			"num_comments": commentsCount,
			"title": title,
			"author": author,
			"created_utc": createdUtc.timeIntervalSince1970,
			"thumbnail": thumbLink?.absoluteString,
			"url_overridden_by_dest": mainImageURL?.absoluteString,
			"thumbnail_height": thumbHeight
		]
	}
	
}

//MARK:- Custom String Convertible
extension Link: CustomStringConvertible {

	var description: String {
		return String("\(createdUtc) \(fullname) `\(String(describing: title).dropFirst(10).prefix(20))`\n")
	}
	
}

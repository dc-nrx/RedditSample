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
	let thumbLink: URL?
	let previewSource: URL?
	
	init?(jsonDict: JSONDict) throws {
		fullname = jsonDict["name"] as! String
		subredditNamePrefixed = jsonDict["subreddit_name_prefixed"] as? String
		title = jsonDict["title"] as? String
		author = jsonDict["author"] as? String
		
		let createdTstamp = jsonDict["created_utc"] as! TimeInterval
		createdUtc = Date(timeIntervalSince1970: createdTstamp)
		
		let urlString = jsonDict["thumbnail"] as? String
		thumbLink = URL(string: urlString ?? "")
		
		if let preview = jsonDict["preview"] as? JSONDict,
		   let imageSourcesJson = preview["images"] as? [JSONDict],
		   let source = imageSourcesJson.first?["url"] as? String {
			previewSource = URL(string: source)
		}
		else {
			previewSource = nil
		}
		
	}
}

//MARK:- Serializable
extension Link {
	
	var json: JSONDict {
		[
			"name": fullname,
			"subreddit_name_prefixed": subredditNamePrefixed,
			"title": title,
			"author": author,
			"created_utc": createdUtc.timeIntervalSince1970,
			"thumbnail": thumbLink?.absoluteString,
			"preview": [
				"images": [
					[
						"source": previewSource?.absoluteString
					]
				]
			]
		]
	}
	
}

//MARK:- Custom String Convertible
extension Link: CustomStringConvertible {

	var description: String {
		return String("\(createdUtc) \(fullname) `\(String(describing: title).dropFirst(10).prefix(20))`\n")
	}
	
}

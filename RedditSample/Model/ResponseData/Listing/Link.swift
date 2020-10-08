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
	let author: String
	let title: String
	let commentsCount: UInt
	let subredditNamePrefixed: String?
	let thumbLink: URL?
	let previewSource: URL?
	
	init?(jsonDict: JSONDict) throws {
		fullname = jsonDict["name"] as! String
		subredditNamePrefixed = jsonDict["subreddit_name_prefixed"] as? String
		author = jsonDict["author"] as! String
		commentsCount = jsonDict["num_comments"] as? UInt ?? 0
		title = jsonDict["title"] as! String
		
		let createdTstamp = jsonDict["created_utc"] as! TimeInterval
		createdUtc = Date(timeIntervalSince1970: createdTstamp)
		
		let urlString = jsonDict["thumbnail"] as? String
		thumbLink = URL(string: urlString ?? "")
		
		if let preview = jsonDict["preview"] as? JSONDict,
		   let imageSourcesJson = preview["images"] as? [JSONDict],
		   let source = imageSourcesJson.first?["source"] as? JSONDict,
		   let urlString = source["url"] as? String {
			previewSource = URL(string: urlString)
		}
		else {
			previewSource = nil
		}
		/// Cache the thumb
		if let previewSource = previewSource {
			ImagesManager.sharedInstance().loadImage(for: previewSource) { _ in }
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
						"source": [
							"url": previewSource?.absoluteString
						]
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

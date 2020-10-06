//
//  Listing.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 02.10.2020.
//

import Foundation

typealias ListingItem = ResponseData & Hashable & Comparable & Codable

struct Listing<T: ListingItem>: RandomAccessCollection, ResponseData, Codable {

	private(set) var after: String?
	
	private var items: [T]
	
	init() {
		items = [T]()
	}
	
	//MARK:- ResponseData
	
	init?(jsonDict: JSONDict) throws {
		let data = jsonDict["data"] as! JSONDict
		after = data["after"] as? String
		
		let children = data["children"] as! [JSONDict]
		let childrenData = children.map { $0["data"] } as! [JSONDict]
		items = try! childrenData.map(T.init(jsonDict:)) as! [T]
	}
	
	//MARK:- RandomAccessCollection
	
	var startIndex: Int { items.startIndex }
	
	var endIndex: Int { items.endIndex}
	
	subscript(position: Int) -> T { items[position] }
	
}

//MARK:- Public
extension Listing {
	
	mutating func removeAll() {
		items.removeAll()
	}
	
	mutating func append(_ anotherListing: Self) {
		after = anotherListing.after
		items.append(contentsOf: anotherListing)
	}
	
}

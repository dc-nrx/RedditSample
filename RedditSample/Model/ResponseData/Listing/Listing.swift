//
//  Listing.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 02.10.2020.
//

import Foundation

typealias ListingItem = ResponseData & Hashable & Comparable

struct Listing<T: ListingItem>: RandomAccessCollection, ResponseData {

	var dist: Int
	
	private var items: [T]
	
	init() {
		dist = 0
		items = [T]()
	}
	
	//MARK:- ResponseData
	
	init?(jsonDict: JSONDict) throws {
		let data = jsonDict["data"] as! JSONDict
		dist = data["dist"] as! Int
		
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
	
	mutating func merge(with anotherListing: Self) {
		dist = Swift.max(dist, anotherListing.dist)
		// Use `united` to avoid double callback in KVO case
		var united = items
		united.append(contentsOf: anotherListing)
		// Remove duplicates & sort
		items = Array(Set(united)).sorted()
	}
	
}

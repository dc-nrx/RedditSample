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
		
		let itemDicts = data["children"] as! [JSONDict]
		items = try! itemDicts.map(T.init(jsonDict:)) as! [T]
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
		items.append(contentsOf: anotherListing)
		// Remove duplicates & sort
		items = Array(Set(items)).sorted()
	}
	
}

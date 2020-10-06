//
//  Listing.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 02.10.2020.
//

import Foundation

typealias ListingItem = ResponseData & Hashable & Comparable

struct Listing<T: ListingItem>: RandomAccessCollection, ResponseData {

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
		let unsorted = try! childrenData.map(T.init(jsonDict:)) as! [T]
		items = unsorted.sorted(by: >)
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
		#warning("pick the correct `after`")
		after = anotherListing.after
		// Use `united` to avoid double callback in KVO case
		var united = items
		united.append(contentsOf: anotherListing)
		// Remove duplicates & sort
		items = Array(Set(united)).sorted(by: >)
	}
	
}

//MARK:- Custom String Convertible
//extension Listing: CustomStringConvertible {
//
//	var desctiption: String {
//
//	}
//
//}

//
//  Serializable.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 06.10.2020.
//

import Foundation

protocol Serializable {
	
	var json: JSONDict { get }
	
}

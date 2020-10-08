//
//  PersistantStore.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 06.10.2020.
//

import Foundation

final class PersistentStore {
	
	static func write(_ item: Serializable, filename: String) {
		
		DispatchQueue.global().async {
			// Get the url of Persons.json in document directory
			guard let documentDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
			let fileUrl = documentDirectoryUrl.appendingPathComponent(filename)

			// Transform array into data and save it into file
			do {
				let data = try JSONSerialization.data(withJSONObject: item.json, options: [])
				try data.write(to: fileUrl, options: [])
			} catch {
				ErrorHandler.shared.process(error: error)
			}
		}
	}
	
	static func read<T: Deserializable>(filename: String, _ completion: @escaping (T?) -> ()) {
		// Get the url of Persons.json in document directory
		guard let documentsDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
			completion(nil)
			return
		}
		let fileUrl = documentsDirectoryUrl.appendingPathComponent(filename)

		let completionOnMain: ((T?) -> ()) = { (result: T?) in
			DispatchQueue.main.async {
				completion(result)
			}
		}
		
		DispatchQueue.global().async {
			do {
				let data = try Data(contentsOf: fileUrl, options: [])
				guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDict,
					  let result = try T(jsonDict: json) else {
					completionOnMain(nil)
					return
				}
				
				completionOnMain(result)
			} catch {
				completionOnMain(nil)
			}
		}
	}
	
}

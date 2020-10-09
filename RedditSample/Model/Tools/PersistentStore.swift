//
//  PersistantStore.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 06.10.2020.
//

import Foundation

///
/// Used to store data between app launches.
/// In the current project used for state restoration only.
///
final class PersistentStore {
	
	///
	/// Specify here the desired directory.
	/// The most common options are `.documentDirectory` (to ensure persistance) or `.cachesDirectory` (to allow cleanup by the system)
	///
	static let directory: FileManager.SearchPathDirectory = .cachesDirectory
	
	///
	/// Write a serializable object on specified path.
	///
	static func write(_ item: Serializable, filename: String) {
		
		DispatchQueue.global().async {
			// Get the url of Persons.json in document directory
			guard let directoryURL = FileManager.default.urls(for: directory, in: .userDomainMask).first else { return }
			let fileUrl = directoryURL.appendingPathComponent(filename)

			// Transform array into data and save it into file
			do {
				let data = try JSONSerialization.data(withJSONObject: item.json, options: [])
				try data.write(to: fileUrl, options: [])
			} catch {
				ErrorHandler.shared.process(error: error)
			}
		}
	}

	///
	/// Read an object from specified path; errors (e.g. `no such file`) are handled sofly by passing `nil` in the completion block.
	///
	static func read<T: Deserializable>(filename: String, _ completion: @escaping (T?) -> ()) {
		// Get the url of Persons.json in document directory
		guard let documentsDirectoryUrl = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
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

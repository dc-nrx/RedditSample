//
//  Network.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

typealias NetworkCallback = (Error?, Data?) -> ()

///
/// The single point to send requests
///
final class Network {
	
	static let shared = Network()
	
	private let session: URLSession = {
		var result = URLSession(configuration: .default)
		return result
	}()
	
	private init() {
		
	}

}

//MARK:- Public
extension Network {
	
	func request(_ request: Target, completion: @escaping NetworkCallback) {
		
		let url = URL(string: "https://www.example.com/")!
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			
			if let error = error {
				DispatchQueue.main.async { completion(error, nil) }
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				(200...299).contains(httpResponse.statusCode) else {
				if self.isTokenExpiredCase(httpResponse: response as! HTTPURLResponse) {
					self.handleTokenExpired(initialRequest: request, completion: completion)
				}
				else {
					DispatchQueue.main.async { completion(error, nil) }
				}
				return
			}
			
			// decode to json
			// run completion
		}
	
		task.resume()
	}
	
}

//MARK:- Private
private extension Network {
	
	func isTokenExpiredCase(httpResponse: HTTPURLResponse) -> Bool {
		return httpResponse.statusCode == 403
	}
	
	///
	/// Try to refresh the token and resend the request once again in success case.
	///
	func handleTokenExpired(initialRequest: Target, completion: @escaping NetworkCallback) {
		
	}
	
}

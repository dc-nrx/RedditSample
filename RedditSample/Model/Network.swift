//
//  Network.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

typealias NetworkCallback = (JSONDict?, NetworkError?) -> ()


enum NetworkError: Error {
	case unexpectedResponseObject
	case reddit(RedditError)
	case http
	case system(Error)
	
}

enum RedditError: String, Error {
	case invalid_grant
	case unknown
	
}


///
/// The single point to send requests
///
final class Network {
	
	static let shared = Network()
	
	private static let errorResponseKey = "error"
	
	private let session: URLSession = {
		var result = URLSession(configuration: .default)
		return result
	}()
	
	private init() {
		
	}

}

//MARK:- Public
extension Network {
	
	///
	/// Expected responses are either empty or JSON
	///
	func request(_ request: Reddit, completion: @escaping NetworkCallback) {
		
		let completionOnMain: NetworkCallback = { (data, error) in
			DispatchQueue.main.async { completion(data, error) }
		}
		
		let task = URLSession.shared.dataTask(with: request.urlRequest) { data, response, error in
			
			// Handle standard errors
			if let error = error {
				DispatchQueue.main.async { completion(nil, .system(error)) }
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse,
				(200...299).contains(httpResponse.statusCode) else {
				// HTTP error
				if self.isTokenExpiredCase(httpResponse: response as! HTTPURLResponse) {
					// Token expired special case - refresh it and resend the request
					self.handleTokenExpired(initialRequest: request, completion: completionOnMain)
				}
				else {
					// Regular case
					DispatchQueue.main.async { completionOnMain(nil, .http) }
				}
				return
			}
			
			// Parse response
			if data == nil {
				completionOnMain(nil, nil)
			}
			else {
				// Only expexted response (if not empty) is a JSON
				if let data = data,
					let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
					let jsonDict = jsonObject as? JSONDict {
					// Check whether it's an error response
					if let errorId = jsonDict[Network.errorResponseKey] as? String {
						completionOnMain(nil, .reddit(RedditError(rawValue: errorId) ?? .unknown))
					}
					else {
						completionOnMain(jsonDict, nil)
					}
				}
				else {
					completionOnMain(nil, NetworkError.unexpectedResponseObject)
				}
			}
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

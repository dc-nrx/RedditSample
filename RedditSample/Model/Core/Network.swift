//
//  Network.swift
//  RedditSample
//
//  Created by Dmytro Chapovskyi on 25.09.2020.
//

import Foundation

typealias NetworkCallback = (JSONDict?, NetworkError?) -> ()

///
/// Custom errors
///
enum NetworkError: Error {
	case unexpectedResponseObject
	case reddit(RedditError)
	case http(HTTPURLResponse?)
	case generic(Error)
}

///
/// Specially handeled Reddit errors (except `unknown`)
///
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
	
	private init() { }

}

//MARK:- Public
extension Network {
	
	///
	/// Expected responses are either empty or JSON
	/// - parameter request: A request to execute (see `API` to add new / change existed requests).
	/// - parameter completion: A completion block; always runs on the main thread.
	///
	func request(_ request: API, completion: @escaping NetworkCallback) {
		
		// Add a convenience wrapper (completion should be run on the main thread)
		let completionOnMain: NetworkCallback = { (data, error) in
			DispatchQueue.main.async { completion(data, error) }
		}
		
		let task = URLSession.shared.dataTask(with: request.urlRequest) { data, response, error in
			
			// Handle standard errors
			if let error = error {
				completionOnMain(nil, .generic(error))
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
					completionOnMain(nil, .http(response as? HTTPURLResponse))
				}
				return
			}
			
			// Parse response (already in the background)
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
					completionOnMain(nil, .unexpectedResponseObject)
				}
			
			}
		}
		
		task.resume()
	}
	
}

//MARK:- Private
private extension Network {
	
	///
	/// Check whether we've got a token expired error which should be handeled in a special way (see `handleTokenExpired...`)
	///
	func isTokenExpiredCase(httpResponse: HTTPURLResponse) -> Bool {
		// Could be at least 401 & 403 (no docs, so just guessing)
		return (400..<500).contains(httpResponse.statusCode)
	}
	
	///
	/// Try to refresh the token and resend the request once again in success case.
	///
	func handleTokenExpired(initialRequest: API, completion: @escaping NetworkCallback) {
		Session.shared.refreshToken { [weak self] error in
			if let error = error {
				DispatchQueue.onMain { completion(nil, .generic(error)) }
			}
			else {
				self?.request(initialRequest, completion: completion)
			}
		}
	}
	
}

//
//  APIClientImplementation.swift
//  Pact-macOS-SPM-Example
//
//  Created by Marko Justinek on 25/10/20.
//

//
//  RestManager.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

//  Copied from https://raw.githubusercontent.com/appcoda/RESTful-Demo/master/RestManager/RestManager.swift
//
//  Expanded the functionality to ignore unsecure SSL certificates.
//

/*
MIT License

Copyright © 2019 Appcoda.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

class RestManager: NSObject, URLSessionDelegate {

	// MARK: - Properties

	var requestHttpHeaders = RestEntity()

	var urlQueryParameters = RestEntity()

	var httpBodyParameters = RestEntity()

	var httpBody: Data?


	// MARK: - Public Methods

	func makeRequest(toURL url: URL,
									 withHttpMethod httpMethod: HttpMethod,
									 completion: @escaping (_ result: Results) -> Void) {

			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
					let targetURL = self?.addURLQueryParameters(toURL: url)
					let httpBody = self?.getHttpBody()

					guard let request = self?.prepareRequest(withURL: targetURL, httpBody: httpBody, httpMethod: httpMethod) else
					{
							completion(Results(withError: CustomError.failedToCreateRequest))
							return
					}

					let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)

					let task = session.dataTask(with: request) { (data, response, error) in
							completion(Results(withData: data,
																 response: Response(fromURLResponse: response),
																 error: error))
					}
					task.resume()
			}
	}



	func getData(fromURL url: URL, completion: @escaping (_ data: Data?) -> Void) {
			DispatchQueue.global(qos: .userInitiated).async {
					let sessionConfiguration = URLSessionConfiguration.default
					let session = URLSession(configuration: sessionConfiguration)
					let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
							guard let data = data else { completion(nil); return }
							completion(data)
					})
					task.resume()
			}
	}



	// MARK: - Private Methods

	private func addURLQueryParameters(toURL url: URL) -> URL {
			if urlQueryParameters.totalItems() > 0 {
					guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
					var queryItems = [URLQueryItem]()
					for (key, value) in urlQueryParameters.allValues() {
							let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))

							queryItems.append(item)
					}

					urlComponents.queryItems = queryItems

					guard let updatedURL = urlComponents.url else { return url }
					return updatedURL
			}

			return url
	}



	private func getHttpBody() -> Data? {
			guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }

			if contentType.contains("application/json") {
					return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [.prettyPrinted, .sortedKeys])
			} else if contentType.contains("application/x-www-form-urlencoded") {
					let bodyString = httpBodyParameters.allValues().map { "\($0)=\(String(describing: $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))" }.joined(separator: "&")
					return bodyString.data(using: .utf8)
			} else {
					return httpBody
			}
	}



	private func prepareRequest(withURL url: URL?, httpBody: Data?, httpMethod: HttpMethod) -> URLRequest? {
			guard let url = url else { return nil }
			var request = URLRequest(url: url)
			request.httpMethod = httpMethod.rawValue

			for (header, value) in requestHttpHeaders.allValues() {
					request.setValue(value, forHTTPHeaderField: header)
			}

			request.httpBody = httpBody
			return request
	}

	// MARK: - Ignore insecure certificates

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard
			challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			(challenge.protectionSpace.host.contains("0.0.0.0") || challenge.protectionSpace.host.contains("localhost")),
			let serverTrust = challenge.protectionSpace.serverTrust
		else {
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let credential = URLCredential(trust: serverTrust)
		completionHandler(.useCredential, credential)
	}

}


// MARK: - RestManager Custom Types

extension RestManager {
	enum HttpMethod: String {
			case get
			case post
			case put
			case patch
			case delete
	}



	struct RestEntity {
			private var values: [String: String] = [:]

			mutating func add(value: String, forKey key: String) {
					values[key] = value
			}

			func value(forKey key: String) -> String? {
					return values[key]
			}

			func allValues() -> [String: String] {
					return values
			}

			func totalItems() -> Int {
					return values.count
			}
	}



	struct Response {
			var response: URLResponse?
			var httpStatusCode: Int = 0
			var headers = RestEntity()

			init(fromURLResponse response: URLResponse?) {
					guard let response = response else { return }
					self.response = response
					httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

					if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
							for (key, value) in headerFields {
									headers.add(value: "\(value)", forKey: "\(key)")
							}
					}
			}
	}



	struct Results {
			var data: Data?
			var response: Response?
			var error: Error?

			init(withData data: Data?, response: Response?, error: Error?) {
					self.data = data
					self.response = response
					self.error = error
			}

			init(withError error: Error) {
					self.error = error
			}
	}



	enum CustomError: Error {
			case failedToCreateRequest
	}
}


// MARK: - Custom Error Description
extension RestManager.CustomError: LocalizedError {
	public var localizedDescription: String {
			switch self {
			case .failedToCreateRequest: return NSLocalizedString("Unable to create the URLRequest object", comment: "")
			}
	}
}


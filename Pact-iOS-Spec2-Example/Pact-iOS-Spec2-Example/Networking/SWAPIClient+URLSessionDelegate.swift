//
//  SWAPIClient+URLSessionDelegate.swift
//  PactMacOSExample
//
//  Created by Marko Justinek on 6/2/21.
//

import Foundation

extension SWAPIClient: URLSessionDelegate {

	public func urlSession(
			_ session: URLSession,
			didReceive challenge: URLAuthenticationChallenge,
			completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
		) {
			guard
				challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
				["localhost", "127.0.0.1", "0.0.0.0"].contains(where: challenge.protectionSpace.host.contains),
				let serverTrust = challenge.protectionSpace.serverTrust
				 else {
					completionHandler(.performDefaultHandling, nil)
					return
			}
			let credential = URLCredential(trust: serverTrust)
			completionHandler(.useCredential, credential)
		}

}

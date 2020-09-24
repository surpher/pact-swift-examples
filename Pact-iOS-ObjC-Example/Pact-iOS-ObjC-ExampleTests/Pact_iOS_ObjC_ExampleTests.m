//
//  Pact_iOS_ObjC_ExampleTests.m
//  Pact-iOS-ObjC-ExampleTests
//
//  Created by Marko Justinek on 24/9/20.
//

#import <XCTest/XCTest.h>
#import <PactSwift/PactSwift.h>

#include "HTTPClient.h"

@interface Pact_iOS_ObjC_ExampleTests: XCTestCase

@property (strong, nonatomic) MockService *mockService;
@property (strong, nonatomic) HTTPClient *httpClient;

@end

@implementation Pact_iOS_ObjC_ExampleTests

- (void)setUp {
	self.mockService = [[MockService alloc] initWithConsumer:@"Consumer-app"
																									provider:@"Provider-server"
																					transferProtocol:TransferProtocolStandard];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPingRequest {
	typedef void (^CompleteBlock)(void);

	// Prepare the provider state
	[[[self.mockService uponReceiving:@"a ping request"]
	 // Prepare the expectations of our request
	 withRequestHTTPMethod:PactHTTPMethodGET path:@"/ping" query:NULL headers:NULL body:NULL]
	 // Prepare the expectations of providers response
	 willRespondWithStatus:200 headers:@{@"Content-Type": @"application/json"} body:@"pong"];

		[self.mockService run:^(CompleteBlock testComplete) {
			// execute the http request to the provider
//				NSString *requestReply = [self.httpClient sayHelloWith];
//				XCTAssertEqualObjects(requestReply, @"Hello");
				testComplete();
			}
		];
}

@end

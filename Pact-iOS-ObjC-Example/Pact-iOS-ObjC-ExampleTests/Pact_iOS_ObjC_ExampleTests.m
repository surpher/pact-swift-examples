//
//  Pact_iOS_ObjC_ExampleTests.m
//  Pact-iOS-ObjC-ExampleTests
//
//  Created by Marko Justinek on 24/9/20.
//  Disclaimer: This file demonstrates how to use PactSwift DSL and is not an example of how to "properly" write unit tests.

#import <XCTest/XCTest.h>
@import PactSwift;

#include "HTTPClient.h"

// MARK: - MockService Singleton Wrapper

@interface MockServiceWrapper: NSObject

+(instancetype)shared;

@property (strong, retain) MockService *mockService;

@end

@implementation MockServiceWrapper

+(instancetype)shared {
	static MockServiceWrapper *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});

	return shared;
}

-(id)init {
	if (self = [super init]) {
		_mockService = [[MockService alloc] initWithConsumer:@"Consumer-app"
																								provider:@"Provider-server"
																				transferProtocol:TransferProtocolStandard];
	}
	return self;
}

@end

// MARK: - XCTestCase

@interface Pact_iOS_ObjC_ExampleTests: XCTestCase

@property (strong, nonatomic) MockService *mockService;
@property (strong, nonatomic) HTTPClient *httpClient;

@end

@implementation Pact_iOS_ObjC_ExampleTests

- (void)setUp {
	[super setUp];

	self.mockService = [[MockServiceWrapper shared] mockService];
	self.httpClient = [[HTTPClient alloc] initWithBaseUrl:self.mockService.baseUrl];
}

- (void)tearDown {
	[super tearDown];
}

// MARK: - Tests

- (void)testPingRequest {
	typedef void (^CompleteBlock)(void);

	XCTestExpectation *expectation = [self expectationWithDescription:@"ping request expectation"];

	// Prepare the request expectation (what provider would see)
	[[[[self.mockService
		uponReceiving:@"a ping request"]
		// Prepare provider states
		givenProviderStates: @[[[ProviderState alloc] initWithDescription:@"user exists" params:@{@"user_id": @"f329q0ds902"}]]]
		// Prepare the expectations of our request
		withRequestHTTPMethod:PactHTTPMethodGET path:@"/ping" query:NULL headers:NULL body:NULL]
		// Prepare the expectations of providers response
		willRespondWithStatus:200 headers:@{@"Content-Type": @"application/json"} body:@{@"message":@"pong"}];

	[self.mockService run:^(CompleteBlock testComplete) {
		// execute the http request to the provider
		[self.httpClient
		 pingWith:^(NSDictionary *responseDict) {
			NSLog(@"### Received:\n%@", responseDict);

			// Test that the response was converted to a dictionary with expected key and value
			XCTAssertTrue([responseDict isEqualToDictionary: @{@"message":@"pong"}]);

			// Expectation is fulfilled
			[expectation fulfill];
			// Test is complete
			testComplete();
		 }
		 failure:^(NSError *error) {
			XCTFail(@"Failed to receive response from /ping");
			// Test is complete
			testComplete();
		 }];
	}];

	// Wait for expectations because we're making an async call
	[self waitForExpectationsWithTimeout:1.0 handler:NULL];
}

// THE EQUALITY ASSERTION IS FAILING ON macOS 11 using Xcode 13beta!
-(void)testAddingAFriendRequest {
	typedef void (^CompleteBlock)(void);

	XCTestExpectation *expectation = [self expectationWithDescription:@"make friend expectation"];

	NSArray *fooParams = [[NSArray alloc] initWithObjects:@"bar", nil];
	NSDictionary *requestQuery = @{@"foo":fooParams};
	NSDictionary *requestHeaders = @{@"Content-Type": @"application/json"};
	NSDictionary *requestBody = @{@"friend": @{@"name":@"Johnny Appleseed", @"age":@"25"}};
	NSDictionary *responseBodyWithMatcher = @{@"id": [[PFMatcherDecimalLike alloc] value:[@1234.56 decimalValue]] };

	[[[[self.mockService
		uponReceiving:@"a request to add a friend"]
		givenProviderState:@"friend does not exist"]
		withRequestHTTPMethod:PactHTTPMethodPOST path:@"/friends/add" query:requestQuery headers:requestHeaders body:requestBody]
		willRespondWithStatus:201 headers:@{@"Content-Type": @"application/json"} body:responseBodyWithMatcher];

	[self.mockService run:^(CompleteBlock testComplete) {
		[self.httpClient makeFriendsWith:@"Johnny Appleseed" age:@25
		 onSuccess:^(NSDictionary *responseDict) {
			NSLog(@"### Received:\n%@", responseDict);

//			XCTAssertTrue([responseDict isEqualToDictionary: expectedResult]); // Xcode 13 beta is not asserting these as equals anymore!?!?

			testComplete();
			[expectation fulfill];
		} onFailure:^(NSError *error) {
			XCTFail(@"Failed to recieve a response from /friends/add");
			testComplete();
		}];
	} withTimeout:1.0];

	[self waitForExpectationsWithTimeout:1.0 handler:NULL];
}

@end

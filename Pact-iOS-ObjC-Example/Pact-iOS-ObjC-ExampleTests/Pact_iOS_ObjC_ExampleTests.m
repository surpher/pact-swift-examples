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

@property (strong, retain) PFMockService *mockService;

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
		_mockService = [[PFMockService alloc] initWithConsumer:@"Consumer-app" provider:@"Provider-server" transferProtocol:TransferProtocolStandard];
	}
	return self;
}

@end

// MARK: - XCTestCase

@interface Pact_iOS_ObjC_ExampleTests: XCTestCase

@property (strong, nonatomic) PFMockService *mockService;

@end

@implementation Pact_iOS_ObjC_ExampleTests

- (void)setUp {
	[super setUp];

	self.mockService = [[MockServiceWrapper shared] mockService];
}

- (void)tearDown {
	[super tearDown];
}

// MARK: - Tests

- (void)testPingRequest {
	typedef void (^__nonnull VoidCompletion)(void);

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

	[self.mockService run:^(NSString *baseURL, VoidCompletion doneHandler) {
		HTTPClient *httpClient = [[HTTPClient alloc] initWithBaseUrl:baseURL];

		// execute the http request to the provider
		[httpClient
		 pingWith:^(NSDictionary *responseDict) {
			NSLog(@"### Received:\n%@", responseDict);

			// Test that the response was converted to a dictionary with expected key and value
			XCTAssertTrue([responseDict isEqualToDictionary: @{@"message":@"pong"}]);

			// Expectation is fulfilled
			[expectation fulfill];
			// Test is complete
			doneHandler();
		 }
		 failure:^(NSError *error) {
			XCTFail(@"Failed to receive response from /ping");
			// Test is complete
			doneHandler();
		 }];
	}];

	// Wait for expectations because we're making an async call
	[self waitForExpectationsWithTimeout:1.0 handler:NULL];
}

// THE EQUALITY ASSERTION IS FAILING ON macOS 11 using Xcode 13beta!
-(void)testAddingAFriendRequest {
	typedef void (^__nonnull VoidCompletion)(void);

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

	[self.mockService run:^(NSString *baseURL, VoidCompletion doneHandler) {
		HTTPClient *httpClient = [[HTTPClient alloc] initWithBaseUrl:baseURL];

		[httpClient makeFriendsWith:@"Johnny Appleseed" age:@25
		 onSuccess:^(NSDictionary *responseDict) {
			NSLog(@"### Received:\n%@", responseDict);

//			XCTAssertTrue([responseDict isEqualToDictionary: expectedResult]); // Xcode 13 beta is not asserting these as equals anymore!?!?

			doneHandler();
			[expectation fulfill];
		} onFailure:^(NSError *error) {
			XCTFail(@"Failed to recieve a response from /friends/add");
			doneHandler();
		}];
	} withTimeout:1.0];

	[self waitForExpectationsWithTimeout:1.0 handler:NULL];
}

@end

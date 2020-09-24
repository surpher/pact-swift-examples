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
																					transferProtocol:0];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end

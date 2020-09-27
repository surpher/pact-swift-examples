//
//  HTTPClient.m
//  Pact-iOS-ObjC-Example
//
//  Created by Marko Justinek on 24/9/20.
//

#import "HTTPClient.h"

@interface HTTPClient()
@property (nonatomic, strong) NSString *baseUrl;
@end

@implementation HTTPClient

- (id)initWithBaseUrl:(NSString *)url {
	if (self = [super init]) {
		self.baseUrl = url;
	}
	return self;
}

-(void)pingWith:(void(^)(NSDictionary *responseDict))success
				failure:(void(^)(NSError* error))failure {
		NSURLSession *session = [NSURLSession sharedSession];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ping", self.baseUrl]];

		NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
																						completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
				NSLog(@"### URL: %@", self.baseUrl);
				NSLog(@"### Response Data: %@",data);
				if (error) {
					failure(error);
				} else {
					NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
					NSLog(@"### Response JSON: %@",json);
					success(json);
				}
			}
		];

	[dataTask resume];
}

-(void)makeFriendsWith:(NSString *)name
									 age:(NSNumber *)age
						 onSuccess:(void(^)(NSDictionary *responseDict))success
						 onFailure:(void(^)(NSError* error))failure {
	NSURLSession *session = [NSURLSession sharedSession];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/friends/add?foo=bar", self.baseUrl]];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

	NSData *httpBody = [[NSString stringWithFormat:@"{\"friend\":{\"name\":\"%@\",\"age\":\"%@\"}}", name, age] dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:httpBody];

	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
																							completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSLog(@"### URL: %@", self.baseUrl);
		NSLog(@"### Response Data: %@",data);
		if (error) {
			failure(error);
		} else {
			NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			NSLog(@"### Response JSON: %@",json);
			success(json);
		}
	}];

	[dataTask resume];
}

@end

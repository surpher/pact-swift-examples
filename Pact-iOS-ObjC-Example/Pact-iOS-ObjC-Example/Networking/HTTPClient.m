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

-(void)sayHelloWith:(void (^)(NSDictionary *responseDict))success
						failure:(void(^)(NSError* error))failure {
		NSURLSession *session = [NSURLSession sharedSession];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.baseUrl, @"sayHello"]];

		NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
																						completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
				NSLog(@"%@",data);
				if (error) {
					failure(error);
				} else {
					NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
					NSLog(@"%@",json);
					success(json);
				}
			}
		];

	[dataTask resume];
}

@end

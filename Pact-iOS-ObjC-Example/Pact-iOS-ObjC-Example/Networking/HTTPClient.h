//
//  HTTPClient.h
//  Pact-iOS-ObjC-Example
//
//  Created by Marko Justinek on 24/9/20.
//

#import <Foundation/Foundation.h>

@interface HTTPClient: NSObject

- (id) initWithBaseUrl:(NSString *)url;

-(void) sayHelloWith:(void (^)(NSDictionary *responseDict))success
				 failure:(void(^)(NSError* error))failure;

//- (NSString *)findFriendsByAgeAndChild;
//
//- (void) unfriend:(void (^)(NSString *response))success failure:(void (^)(NSInteger errorCode))failure;

@end

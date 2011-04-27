//
//  MixioAuthTokenManager.h
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MixioAuthToken.h"

@interface MixioAuthTokenManager : NSObject {
}

- (void)getAccessTokenWithAuthorizationCode:(NSString *)code consumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret
								redirectURL:(NSURL *)aURL completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler;

- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken consumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret
					 completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler;
- (void)refreshToken:(MixioAuthToken *)token completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler;

@end

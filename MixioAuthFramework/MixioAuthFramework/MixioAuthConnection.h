//
//  MixioAuthConnection.h
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MixioAuthToken.h"

@interface MixioAuthConnection : NSObject {
    BOOL code401Received;
}

- (void)connectToURL:(NSURL *)aURL token:(MixioAuthToken *)token refreshHandler:(void(^)(MixioAuthToken *oAuthToken, void(^refreshCompletionHandler)(MixioAuthToken *oAuthToken, NSError* error)))refreshHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler;
- (void)connectToURL:(NSURL *)aURL accessToken:(NSString *)accessToken refreshHandler:(void(^)(MixioAuthToken *oAuthToken, void(^refreshCompletionHandler)(MixioAuthToken *oAuthToken, NSError* error)))refreshHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandle;
@end

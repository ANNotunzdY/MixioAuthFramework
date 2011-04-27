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
    
}

- (void)connectToURL:(NSURL *)aURL token:(MixioAuthToken *)token refreshingHandler:(void(^)(MixioAuthToken *oAuthToken))refreshingHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler;
- (void)connectToURL:(NSURL *)aURL accessToken:(NSString *)accessToken completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler;
@end

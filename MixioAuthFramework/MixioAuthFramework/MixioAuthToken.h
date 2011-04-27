//
//  MixioAuthToken.h
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MixioAuthToken : NSObject {
}
@property (nonatomic, retain) NSString* accessToken;
@property (nonatomic, retain) NSString* refreshToken;
@property (nonatomic, retain) NSDate* expireDate;

+ (MixioAuthToken *)oAuthTokenWithAccessToken:(NSString *)aAccessToken refreshToken:(NSString *)aRefreshToken expireInterval:(int)seconds;
- (void)saveToStandardUserDefaults;

@end

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
@property (nonatomic, retain) NSString* consumerKey;
@property (nonatomic, retain) NSString* consumerSecret;

+ (MixioAuthToken *)oAuthTokenWithAccessToken:(NSString *)aAccessToken refreshToken:(NSString *)aRefreshToken expireInterval:(int)seconds consumerKey:aConsumerKey consumerSecret:aConsumerSecret;
- (void)saveToStandardUserDefaults;
+ (MixioAuthToken *)loadFromStandardUserDefaults;
+ (void)removeTokenFromUserDefaults;

@end

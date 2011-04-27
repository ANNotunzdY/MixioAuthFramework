//
//  MixioAuthToken.m
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthToken.h"


@implementation MixioAuthToken

@synthesize accessToken, refreshToken, expireDate, consumerKey, consumerSecret;

- (void)dealloc {
	[accessToken release];
	[refreshToken release];
	[expireDate release];
	[super dealloc];
}

+ (MixioAuthToken *)oAuthTokenWithAccessToken:(NSString *)aAccessToken refreshToken:(NSString *)aRefreshToken expireInterval:(int)seconds consumerKey:aConsumerKey consumerSecret:aConsumerSecret {
	MixioAuthToken* oAuthToken = [[[MixioAuthToken alloc] init] autorelease];
	oAuthToken.accessToken = aAccessToken;
	oAuthToken.refreshToken = aRefreshToken;
	oAuthToken.expireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
	oAuthToken.consumerKey = aConsumerKey;
	oAuthToken.consumerSecret = aConsumerSecret;
	return oAuthToken;
}

- (NSString *)description {
	return [[NSDictionary dictionaryWithObjectsAndKeys:
			 accessToken, @"accessToken", 
			 refreshToken, @"refreshToken",
			 expireDate, @"expireDate",
			 nil] description];
}

- (void)saveToStandardUserDefaults {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
	 accessToken, @"accessToken", 
	 refreshToken, @"refreshToken",
	 [NSNumber numberWithDouble:[expireDate timeIntervalSince1970]], @"expireDate",
	 consumerKey, @"consumerKey",
	 consumerSecret, @"consumerSecret",
	 nil];
	[defaults setObject:dictionary forKey:@"MixioAuthToken"];
	[defaults synchronize];
}

+ (MixioAuthToken *)loadFromStandardUserDefaults {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* dictionary = [defaults objectForKey:@"MixioAuthToken"];
	if (!dictionary) {
		return nil;
	}
	MixioAuthToken* oAuthToken = [[[MixioAuthToken alloc] init] autorelease];
	oAuthToken.accessToken = [dictionary objectForKey:@"accessToken"];
	oAuthToken.refreshToken = [dictionary objectForKey:@"refreshToken"];
	oAuthToken.expireDate = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"expireDate"] doubleValue]];
	oAuthToken.consumerKey = [dictionary objectForKey:@"consumerKey"];
	oAuthToken.consumerSecret = [dictionary objectForKey:@"consumerSecret"];
	return oAuthToken;
}

+ (void)removeTokenFromUserDefaults {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"MixioAuthToken"];
	[defaults synchronize];
}

@end

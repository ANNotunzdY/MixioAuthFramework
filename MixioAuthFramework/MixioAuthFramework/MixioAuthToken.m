//
//  MixioAuthToken.m
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthToken.h"


@implementation MixioAuthToken

@synthesize accessToken, refreshToken, expireDate;

- (void)dealloc {
	[accessToken release];
	[refreshToken release];
	[expireDate release];
	[super dealloc];
}

+ (MixioAuthToken *)oAuthTokenWithAccessToken:(NSString *)aAccessToken refreshToken:(NSString *)aRefreshToken expireInterval:(int)seconds {
	MixioAuthToken* oAuthToken = [[[MixioAuthToken alloc] init] autorelease];
	oAuthToken.accessToken = aAccessToken;
	oAuthToken.refreshToken = aRefreshToken;
	oAuthToken.expireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
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
	 [expireDate description], @"expireDate",
	 nil];
	[defaults setObject:dictionary forKey:@"MixioAuthToken"];
	[defaults synchronize];
}

@end

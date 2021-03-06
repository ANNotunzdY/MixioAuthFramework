//
//  MixioAuthTokenManager.m
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthTokenManager.h"
#import "JSON.h"

NSString* const kMixioAuthTokenRefreshURLString = @"https://secure.mixi-platform.com/2/token";

@interface MixioAuthTokenManager ()
@property (copy, nonatomic) void (^completionHandler)(MixioAuthToken* oAuthToken, NSError *error);
@property (retain, nonatomic) NSMutableData* receivedData;
@property (retain, nonatomic) NSString* consumerKey;
@property (retain, nonatomic) NSString* consumerSecret;
@end

@implementation MixioAuthTokenManager;

@synthesize completionHandler, receivedData, consumerKey, consumerSecret;

- (void)dealloc {
	[completionHandler release];
	[receivedData release];
	[super dealloc];
}

- (void)getAccessTokenWithAuthorizationCode:(NSString *)code consumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret
								redirectURL:(NSURL *)aURL completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler {
	
	if (self.completionHandler) {
		aCompletionHandler(nil, nil);
		return;
	}
	
	self.completionHandler = aCompletionHandler;
	self.consumerKey = aConsumerKey;
	self.consumerSecret = aConsumerSecret;
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMixioAuthTokenRefreshURLString]];
	NSString* bodyString = [NSString stringWithFormat:@"grant_type=authorization_code&client_id=%@&client_secret=%@&code=%@&redirect_uri=%@", aConsumerKey, aConsumerSecret, code, [aURL absoluteString]];
	[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPMethod:@"POST"];
	
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		self.receivedData = [NSMutableData data];
		[connection start];
	} else {
		if (self.completionHandler) {
			completionHandler(nil, [NSError errorWithDomain:@"MixioAuthTokenManagerErrorDomain" code:1 userInfo:nil]);
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (self.completionHandler) {
		completionHandler(nil, error);
	}
	self.completionHandler = nil;
	[connection release];
	self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString* receiveString = [[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease];
	NSDictionary* jsonDictionary = [receiveString JSONValue];
	
	if (self.completionHandler) {
		if ([jsonDictionary objectForKey:@"access_token"]) {
			MixioAuthToken* token = [MixioAuthToken oAuthTokenWithAccessToken:[jsonDictionary objectForKey:@"access_token"] refreshToken:[jsonDictionary objectForKey:@"refresh_token"] expireInterval:[[jsonDictionary objectForKey:@"expires_in"] intValue] consumerKey:self.consumerKey consumerSecret:self.consumerSecret];
			completionHandler(token, nil);
		} else {
			completionHandler(nil, [NSError errorWithDomain:@"MixioAuthTokenManagerErrorDomain" code:0 userInfo:[NSDictionary dictionaryWithObject:receiveString forKey:NSLocalizedDescriptionKey]]);
		}
		self.completionHandler = nil;
	}
	
	[connection release];
	self.receivedData = nil;
}

- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken consumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret
					 completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler {
	
	if (self.completionHandler) {
		aCompletionHandler(nil, nil);
		return;
	}
	
	self.completionHandler = aCompletionHandler;
	self.consumerKey = aConsumerKey;
	self.consumerSecret = aConsumerSecret;
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMixioAuthTokenRefreshURLString]];
	NSString* bodyString = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@", aConsumerKey, aConsumerSecret, refreshToken];
	[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPMethod:@"POST"];
	
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		self.receivedData = [NSMutableData data];
		[connection start];
	} else {
		if (self.completionHandler) {
			completionHandler(nil, [NSError errorWithDomain:@"MixioAuthTokenManagerErrorDomain" code:1 userInfo:nil]);
		}
	}
}

- (void)refreshToken:(MixioAuthToken *)token completionHandler:(void(^)(MixioAuthToken* oAuthToken, NSError *error))aCompletionHandler {
	[self getAccessTokenWithRefreshToken:token.refreshToken consumerKey:token.consumerKey consumerSecret:token.consumerSecret completionHandler:aCompletionHandler];
}

@end
